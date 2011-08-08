require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'
require 'database_cleaner/active_record/truncation'
# This file may seem to have duplication with that of truncation, but by keeping them separate
# we avoiding loading this code when it is not being used (which is the common case).

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < MYSQL_ADAPTER_PARENT
      def drop_table(table_name)
        execute("DROP #{quote_table_name(table_name)};")
      end
    end

    class Mysql2Adapter < AbstractAdapter
      def drop_table(table_name)
        execute("DROP #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter < AbstractAdapter
      def drop_table(table_name)
          execute("DROP #{quote_table_name(table_name)};")
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def drop_table(table_name)
        execute("DROP #{quote_table_name(table_name)};")
      end
    end

    class SQLServerAdapter < AbstractAdapter
      def drop_table(table_name)
        execute("DROP #{quote_table_name(table_name)};")
      end
    end

    class OracleEnhancedAdapter < AbstractAdapter
      def drop_table(table_name)
        execute("DROP #{quote_table_name(table_name)}")
      end
    end
  end
end


module DatabaseCleaner::ActiveRecord
  class Drop < Truncation

    def clean
      each_table do |connection, table_name|
        connection.drop_table table_name if connection
      end
    end

    # drop all tables if no args given
    def drop_tables *table_names
      tables_to_affect = table_names.empty? ? all_tables : table_names

      each_table do |connection, table_name|
        connection.drop_table(table_name) if connection && drop_table?(table_name)
      end
    end

    protected

    def tables_to_drop
      tables_to_truncate(connection)
    end

    def drop_table? tables, table
      return true if tables.flatten.empty?
      tables_to_affect.include?(table.to_s)
    end

    def each_table
      tables_to_drop.each do |table|
        yield connection, table
      end
    end
  end
end


