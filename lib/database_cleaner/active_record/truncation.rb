require 'active_record/base'

require 'active_record/connection_adapters/abstract_adapter'

#Load available connection adapters
%w(
  abstract_mysql_adapter postgresql_adapter sqlite3_adapter mysql_adapter mysql2_adapter
).each do |known_adapter|
  begin
    require "active_record/connection_adapters/#{known_adapter}"
  rescue LoadError
  end
end

require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'

module DatabaseCleaner
  module ConnectionAdapters

    module AbstractAdapter
      # used to be called views but that can clash with gems like schema_plus
      # this gem is not meant to be exposing such an extra interface any way
      def database_cleaner_view_cache
        @views ||= select_values("select table_name from information_schema.views where table_schema = '#{current_database}'") rescue []
      end

      def database_cleaner_table_cache
        # the adapters don't do caching (#130) but we make the assumption that the list stays the same in tests
        @database_cleaner_tables ||= ::ActiveRecord::VERSION::MAJOR >= 5 ? data_sources : tables
      end

      def truncate_table(table_name)
        raise NotImplementedError
      end

      def truncate_tables(tables)
        tables.each do |table_name|
          self.truncate_table(table_name)
        end
      end
    end

    module AbstractMysqlAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end

      def truncate_tables(tables)
        tables.each { |t| truncate_table(t) }
      end

      def pre_count_truncate_tables(tables, options = {:reset_ids => true})
        filter = options[:reset_ids] ? method(:has_been_used?) : method(:has_rows?)
        truncate_tables(tables.select(&filter))
      end

      private

      def row_count(table)
        # Patch for MysqlAdapter with ActiveRecord 3.2.7 later
        # select_value("SELECT 1") #=> "1"
        select_value("SELECT EXISTS (SELECT 1 FROM #{quote_table_name(table)} LIMIT 1)").to_i
      end

      # Returns a boolean indicating if the given table has an auto-inc number higher than 0.
      # Note, this is different than an empty table since an table may populated, the index increased,
      # but then the table is cleaned.  In other words, this function tells us if the given table
      # was ever inserted into.
      def has_been_used?(table)
        if has_rows?(table)
          true
        else
          # Patch for MysqlAdapter with ActiveRecord 3.2.7 later
          # select_value("SELECT 1") #=> "1"
          select_value(<<-SQL).to_i > 1 # returns nil if not present
          SELECT Auto_increment
          FROM information_schema.tables
          WHERE table_name='#{table}';
          SQL
        end
      end

      def has_rows?(table)
        row_count(table) > 0
      end
    end

    module IBM_DBAdapter
      def truncate_table(table_name)
        execute("TRUNCATE #{quote_table_name(table_name)} IMMEDIATE")
      end
    end

    module SQLiteAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
        if uses_sequence
          execute("DELETE FROM sqlite_sequence where name = '#{table_name}';")
        end
      end
      alias truncate_table delete_table

      def truncate_tables(tables)
        tables.each { |t| truncate_table(t) }
      end

      private

      # Returns a boolean indicating if the SQLite database is using the sqlite_sequence table.
      def uses_sequence
        select_value("SELECT name FROM sqlite_master WHERE type='table' AND name='sqlite_sequence';")
      end
    end

    module TruncateOrDelete
      def truncate_table(table_name)
        begin
          execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
        rescue ::ActiveRecord::StatementInvalid
          execute("DELETE FROM #{quote_table_name(table_name)};")
        end
      end
    end

    module OracleAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}")
      end
    end

    module PostgreSQLAdapter
      def db_version
        @db_version ||= postgresql_version
      end

      def cascade
        @cascade ||= db_version >=  80200 ? 'CASCADE' : ''
      end

      def restart_identity
        @restart_identity ||= db_version >=  80400 ? 'RESTART IDENTITY' : ''
      end

      def truncate_table(table_name)
        truncate_tables([table_name])
      end

      def truncate_tables(table_names)
        return if table_names.nil? || table_names.empty?
        execute("TRUNCATE TABLE #{table_names.map{|name| quote_table_name(name)}.join(', ')} #{restart_identity} #{cascade};")
      end

      def pre_count_truncate_tables(tables, options = {:reset_ids => true})
        filter = options[:reset_ids] ? method(:has_been_used?) : method(:has_rows?)
        truncate_tables(tables.select(&filter))
      end

      def database_cleaner_table_cache
        # AR returns a list of tables without schema but then returns a
        # migrations table with the schema. There are other problems, too,
        # with using the base list. If a table exists in multiple schemas
        # within the search path, truncation without the schema name could
        # result in confusing, if not unexpected results.
        @database_cleaner_tables ||= tables_with_schema
      end

      private

      # Returns a boolean indicating if the given table has an auto-inc number higher than 0.
      # Note, this is different than an empty table since an table may populated, the index increased,
      # but then the table is cleaned.  In other words, this function tells us if the given table
      # was ever inserted into.
      def has_been_used?(table)
        return has_rows?(table) unless has_sequence?(table)

        cur_val = select_value("SELECT currval('#{table}_id_seq');").to_i rescue 0
        cur_val > 0
      end

      def has_sequence?(table)
        select_value("SELECT true FROM pg_class WHERE relname = '#{table}_id_seq';")
      end

      def has_rows?(table)
        select_value("SELECT true FROM #{table} LIMIT 1;")
      end

      def tables_with_schema
        rows = select_rows <<-_SQL
          SELECT schemaname || '.' || tablename
          FROM pg_tables
          WHERE
            tablename !~ '_prt_' AND
            #{::DatabaseCleaner::ActiveRecord::Base.exclusion_condition('tablename')} AND
            schemaname = ANY (current_schemas(false))
        _SQL
        rows.collect { |result| result.first }
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    #Apply adapter decoraters where applicable (adapter should be loaded)
    AbstractAdapter.class_eval { include DatabaseCleaner::ConnectionAdapters::AbstractAdapter }

    if defined?(JdbcAdapter)
      if defined?(OracleJdbcConnection)
        JdbcAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::OracleAdapter }
      else
        JdbcAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::TruncateOrDelete }
      end
    end
    AbstractMysqlAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::AbstractMysqlAdapter } if defined?(AbstractMysqlAdapter)
    Mysql2Adapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::AbstractMysqlAdapter } if defined?(Mysql2Adapter)
    MysqlAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::AbstractMysqlAdapter } if defined?(MysqlAdapter)
    SQLiteAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::SQLiteAdapter } if defined?(SQLiteAdapter)
    SQLite3Adapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::SQLiteAdapter } if defined?(SQLite3Adapter)
    PostgreSQLAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::PostgreSQLAdapter } if defined?(PostgreSQLAdapter)
    IBM_DBAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::IBM_DBAdapter } if defined?(IBM_DBAdapter)
    SQLServerAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::TruncateOrDelete } if defined?(SQLServerAdapter)
    OracleEnhancedAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::OracleAdapter } if defined?(OracleEnhancedAdapter)
  end
end

module DatabaseCleaner::ActiveRecord
  class Truncation
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Truncation

    def clean
      connection = connection_class.connection
      connection.disable_referential_integrity do
        if pre_count? && connection.respond_to?(:pre_count_truncate_tables)
          connection.pre_count_truncate_tables(tables_to_truncate(connection), {:reset_ids => reset_ids?})
        else
          connection.truncate_tables(tables_to_truncate(connection))
        end
      end
    end

    private

    def tables_to_truncate(connection)
      tables_in_db = cache_tables? ? connection.database_cleaner_table_cache : connection.tables
      to_reject = (@tables_to_exclude + connection.database_cleaner_view_cache)
      (@only || tables_in_db).reject do |table|
        if ( m = table.match(/([^.]+)$/) )
          to_reject.include?(m[1])
        else
          false
        end
      end
    end

    # overwritten
    def migration_storage_names
      [::DatabaseCleaner::ActiveRecord::Base.migration_table_name]
    end

    def cache_tables?
      !!@cache_tables
    end

    def pre_count?
      @pre_count == true
    end

    def reset_ids?
      @reset_ids != false
    end
  end
end
