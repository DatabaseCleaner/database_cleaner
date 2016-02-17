require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'
require 'database_cleaner/active_record/truncation'

module DatabaseCleaner
  module ConnectionAdapters
    module AbstractDeleteAdapter
      def delete_table(table_name)
        raise NotImplementedError
      end
    end

    module GenericDeleteAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    module OracleDeleteAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)}")
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    AbstractAdapter.class_eval { include DatabaseCleaner::ConnectionAdapters::AbstractDeleteAdapter }

    JdbcAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(JdbcAdapter)
    AbstractMysqlAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(AbstractMysqlAdapter)
    Mysql2Adapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(Mysql2Adapter)
    SQLiteAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(SQLiteAdapter)
    SQLite3Adapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(SQLite3Adapter)
    PostgreSQLAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(PostgreSQLAdapter)
    IBM_DBAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(IBM_DBAdapter)
    SQLServerAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::GenericDeleteAdapter } if defined?(SQLServerAdapter)
    OracleEnhancedAdapter.class_eval { include ::DatabaseCleaner::ConnectionAdapters::OracleDeleteAdapter } if defined?(OracleEnhancedAdapter)
  end
end

module DatabaseCleaner::ActiveRecord
  module SelectiveTruncation
    def tables_to_truncate(connection)
      if information_schema_exists?(connection)
        (@only || tables_with_new_rows(connection)) - @tables_to_exclude
      else
        super
      end
    end

    def tables_with_new_rows(connection)
      @db_name ||= connection.instance_variable_get('@config')[:database]
      result = connection.exec_query("SELECT table_name FROM information_schema.tables WHERE table_schema = '#{@db_name}' AND table_rows > 0")
      result.map{ |row| row['table_name'] } - ['schema_migrations']
    end

    def information_schema_exists? connection
      return false unless connection.is_a? ActiveRecord::ConnectionAdapters::Mysql2Adapter
      @information_schema_exists ||=
        begin
          connection.execute("SELECT 1 FROM information_schema.tables")
          true
        rescue
          false
        end
    end
  end

  class Deletion < Truncation
    if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      include SelectiveTruncation
    end

    def clean
      connection = connection_class.connection
      connection.disable_referential_integrity do
        tables_to_truncate(connection).each do |table_name|
          connection.delete_table table_name
        end
      end
    end
  end
end
