require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'

module ActiveRecord
  module ConnectionAdapters
    # Activerecord-jdbc-adapter defines class dependencies a bit differently - if it is present, confirm to ArJdbc hierarchy to avoid 'superclass mismatch' errors.
    USE_ARJDBC_WORKAROUND = defined?(ArJdbc)

    class AbstractAdapter
      def views
        @views ||= select_values("select table_name from information_schema.views where table_schema = '#{current_database}'") rescue []
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

    unless USE_ARJDBC_WORKAROUND
      class SQLiteAdapter < AbstractAdapter
      end
    end

    # ActiveRecord 3.1 support
    if defined?(AbstractMysqlAdapter)
      MYSQL_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractMysqlAdapter
      MYSQL2_ADAPTER_PARENT = AbstractMysqlAdapter
    else
      MYSQL_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractAdapter
      MYSQL2_ADAPTER_PARENT = AbstractAdapter
    end
    
    SQLITE_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : SQLiteAdapter
    POSTGRE_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractAdapter

    class MysqlAdapter < MYSQL_ADAPTER_PARENT
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class Mysql2Adapter < MYSQL2_ADAPTER_PARENT
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class IBM_DBAdapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE #{quote_table_name(table_name)} IMMEDIATE")
      end
    end

    class SQLite3Adapter < SQLITE_ADAPTER_PARENT
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
        execute("DELETE FROM sqlite_sequence where name = '#{table_name}';")
      end
      alias truncate_table delete_table
    end

    class JdbcAdapter < AbstractAdapter
      def truncate_table(table_name)
        begin
          execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
        rescue ActiveRecord::StatementInvalid
          execute("DELETE FROM #{quote_table_name(table_name)};")
        end
      end
    end

    class PostgreSQLAdapter < POSTGRE_ADAPTER_PARENT

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

    end

    class SQLServerAdapter < AbstractAdapter
      def truncate_table(table_name)
        begin
          execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
        rescue ActiveRecord::StatementInvalid
          execute("DELETE FROM #{quote_table_name(table_name)};")
        end
      end
    end

    class OracleEnhancedAdapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Truncation
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Truncation

    def clean
      connection = connection_klass.connection
      connection.disable_referential_integrity do
        connection.truncate_tables(tables_to_truncate(connection))
      end
    end

    private

    def tables_to_truncate(connection)
       (@only || connection.tables) - @tables_to_exclude - connection.views
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end

  end
end



