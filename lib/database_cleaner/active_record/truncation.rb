require "database_cleaner/truncation_base"

module ActiveRecord
  module ConnectionAdapters

    class MysqlAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class SQLite3Adapter
      def truncate_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class PostgreSQLAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)} CASCADE;")
      end
    end

    class SQLServerAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class OracleEnhancedAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Truncation < ::DatabaseCleaner::TruncationBase

    def clean
      connection.disable_referential_integrity do
        tables_to_truncate.each do |table_name|
          connection.truncate_table table_name
        end
      end
    end

    private

    def tables_to_truncate
      (@only || connection.tables) - @tables_to_exclude
    end

    def connection
      ::ActiveRecord::Base.connection
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end

  end
end


