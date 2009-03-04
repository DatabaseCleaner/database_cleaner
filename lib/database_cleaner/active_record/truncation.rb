
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def truncate_tabe(table_name)
        execute("TRUNCATE TABLE #{table_name};")
      end
    end

    class SQLite3Adapter
      def truncate_table(table_name)
        execute("DELETE FROM #{table_name};")
      end
    end

  end

end


module DatabaseCleaner::ActiveRecord
  class Truncation

    def start
      # no-op
    end


    def clean
      connection.disable_referential_integrity do
        (connection.tables - %w{schema_migrations}).each do |table_name|
          connection.truncate_table table_name
        end
      end
  end

  private

    def connection
      ActiveRecord::Base.connection
    end

  end

end


