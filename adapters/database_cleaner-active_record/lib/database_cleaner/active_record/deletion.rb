require 'active_record'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
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
      stats = table_stats_query(connection)
      if stats != ''
        connection.select_values(stats)
      else
        []
      end
    end

    def table_stats_query(connection)
      @table_stats_query ||= build_table_stats_query(connection)
    ensure
      @table_stats_query = nil unless @cache_tables
    end

    def build_table_stats_query(connection)
      tables = connection.select_values(<<-SQL)
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = database()
        AND #{::DatabaseCleaner::ActiveRecord::Base.exclusion_condition('table_name')};
      SQL
      queries = tables.map do |table|
        "(SELECT #{connection.quote(table)} FROM #{connection.quote_table_name(table)} LIMIT 1)"
      end
      queries.join(' UNION ALL ')
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
