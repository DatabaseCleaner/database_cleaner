require 'active_record/base'

require 'active_record/connection_adapters/abstract_adapter'

begin
  require 'active_record/connection_adapters/abstract_mysql_adapter'
rescue LoadError
end

require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'

module DatabaseCleaner
  module ActiveRecord

    module AbstractAdapter
      # used to be called views but that can clash with gems like schema_plus
      # this gem is not meant to be exposing such an extra interface any way
      def database_cleaner_view_cache
        @views ||= select_values("select table_name from information_schema.views where table_schema = '#{current_database}'") rescue []
      end

      def database_cleaner_table_cache
        # the adapters don't do caching (#130) but we make the assumption that the list stays the same in tests
        @database_cleaner_tables ||= tables
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

    module MysqlAdapter

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
        if row_count(table) > 0
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
        rescue ActiveRecord::StatementInvalid
          execute("DELETE FROM #{quote_table_name(table_name)};")
        end
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

      private

      # Returns a boolean indicating if the given table has an auto-inc number higher than 0.
      # Note, this is different than an empty table since an table may populated, the index increased,
      # but then the table is cleaned.  In other words, this function tells us if the given table
      # was ever inserted into.
      def has_been_used?(table)
        cur_val = select_value("SELECT currval('#{table}_id_seq');").to_i rescue 0
        cur_val > 0
      end

      def has_rows?(table)
        select_value("SELECT true FROM #{table} LIMIT 1;")
      end
    end

    module OracleEnhancedAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}")
      end
    end

  end
end

#TODO: Remove monkeypatching and decorate the connection instead!

module ActiveRecord
  module ConnectionAdapters
    # Activerecord-jdbc-adapter defines class dependencies a bit differently - if it is present, confirm to ArJdbc hierarchy to avoid 'superclass mismatch' errors.
    USE_ARJDBC_WORKAROUND = defined?(ArJdbc)
    # ActiveRecord 3.1+ support
    MYSQL_ABSTRACT_ADAPTER = defined?(AbstractMysqlAdapter) ? AbstractMysqlAdapter : AbstractAdapter

    AbstractAdapter.send(:include, ::DatabaseCleaner::ActiveRecord::AbstractAdapter)

    if USE_ARJDBC_WORKAROUND
      MYSQL_ADAPTER_PARENT  = JdbcAdapter
    else
      MYSQL_ADAPTER_PARENT  = MYSQL_ABSTRACT_ADAPTER
      class SQLiteAdapter < AbstractAdapter; end
    end
    MYSQL2_ADAPTER_PARENT = MYSQL_ABSTRACT_ADAPTER

    if defined?(SQLite3Adapter) && SQLite3Adapter.superclass == ActiveRecord::ConnectionAdapters::AbstractAdapter
      SQLITE_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractAdapter
    else
      SQLITE_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : SQLiteAdapter
    end
    POSTGRES_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractAdapter

    MYSQL_ADAPTER_PARENT.class_eval     { include ::DatabaseCleaner::ActiveRecord::MysqlAdapter }
    MYSQL2_ADAPTER_PARENT.class_eval    { include ::DatabaseCleaner::ActiveRecord::MysqlAdapter }
    SQLITE_ADAPTER_PARENT.class_eval    { include ::DatabaseCleaner::ActiveRecord::SQLiteAdapter }
    POSTGRES_ADAPTER_PARENT.class_eval  { include ::DatabaseCleaner::ActiveRecord::PostgreSQLAdapter }

    class IBM_DBAdapter < AbstractAdapter
      include ::DatabaseCleaner::ActiveRecord::IBM_DBAdapter
    end

    class JdbcAdapter < AbstractAdapter
      include ::DatabaseCleaner::ActiveRecord::TruncateOrDelete
    end

    class SQLServerAdapter < AbstractAdapter
      include ::DatabaseCleaner::ActiveRecord::TruncateOrDelete
    end

    class OracleEnhancedAdapter < AbstractAdapter
      include ::DatabaseCleaner::ActiveRecord::OracleEnhancedAdapter
    end
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
      (@only || connection.database_cleaner_table_cache) - @tables_to_exclude - connection.database_cleaner_view_cache
    end

    # overwritten
    def migration_storage_names
      [::ActiveRecord::Migrator.schema_migrations_table_name]
    end

    def pre_count?
      @pre_count == true
    end

    def reset_ids?
      @reset_ids != false
    end
  end
end
