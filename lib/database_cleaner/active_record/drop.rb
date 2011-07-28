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

    def drop
      each_table do |connection, table_name|
        connection.drop_table table_name if connection
      end
    end

    def drop_tables *table_names 
      table_names = table_names.flatten.uniq.map(&:to_s)
      each_table do |connection, table_name|
        connection.drop_table(table_name)  if connection && drop_table?(table_names, table_name)          
      end
    end
    
    protected
    
    def drop_table? tables, table
      # return false if special_table.include? table.upcase
      return true if tables.flatten.empty?
      tables.include?(table.to_s)
    end 

    def each_table
      tables_to_drop.each do |table|
        yield connection, table
      end
    end

    def tables_to_drop
      connection.tables - special_tables
    end

    def special_tables
      special_tables_map[:sqlite] + special_tables_map[:mysql]     
    end
    
    def special_tables_map
      {
        :sqlite => ['SQLITE_TEMP_MASTER', 'SQLITE_MASTER'],
        :mysql => ['INFORMATION_SCHEMA']
      }
    end
  end
end


