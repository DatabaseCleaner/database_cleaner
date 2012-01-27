require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'
require 'database_cleaner/active_record/truncation'
# This file may seem to have duplication with that of truncation, but by keeping them separate
# we avoiding loading this code when it is not being used (which is the common case).

module ActiveRecord
  module ConnectionAdapters

    MysqlAdapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end if defined?(MysqlAdapter)

    Mysql2Adapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end if defined?(Mysql2Adapter)

    JdbcAdapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end if defined?(JdbcAdapter)

    PostgreSQLAdapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end if defined?(PostgreSQLAdapter)

    SQLServerAdapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end if defined?(SQLServerAdapter)

    OracleEnhancedAdapter.class_eval do
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)}")
      end
    end if defined?(OracleEnhancedAdapter)

  end
end


module DatabaseCleaner::ActiveRecord
  class Deletion < Truncation

    def clean
      connection = connection_klass.connection
      connection.disable_referential_integrity do
        tables_to_truncate(connection).each do |table_name|
          connection.delete_table table_name
        end
      end
    end

  end
end


