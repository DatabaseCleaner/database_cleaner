require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'
require 'database_cleaner/active_record/truncation'

module ActiveRecord
  module ConnectionAdapters

    class AbstractAdapter
    end

    class SQLiteAdapter < AbstractAdapter
    end

    class MysqlAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class Mysql2Adapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class SQLite3Adapter < SQLiteAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter < AbstractAdapter
      def delete_table(table_name)
          execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class SQLServerAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class OracleEnhancedAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)}")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Deletion < Truncation

    def clean
      connection.disable_referential_integrity do
        tables_to_truncate.each do |table_name|
          connection.delete_table table_name
        end
      end
    end

  end
end


