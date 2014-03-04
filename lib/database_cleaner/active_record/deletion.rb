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
  class Deletion < Truncation
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
