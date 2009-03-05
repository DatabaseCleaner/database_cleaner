
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{table_name};")
      end
    end

    class SQLite3Adapter
      def truncate_table(table_name)
        execute("DELETE FROM #{table_name};")
      end
    end

    class JdbcAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{table_name};")
      end
    end

  end

end


module DatabaseCleaner::ActiveRecord
  class Truncation

    def initialize(options={})
      if !options.empty? && !(options.keys - [:only, :except]).empty?
        raise ArgumentError, "The only valid options are :only and :except. You specified #{options.keys.join(',')}."
      end
      if options.has_key?(:only) && options.has_key?(:except)
        raise ArgumentError, "You may only specify either :only or :either.  Doing both doesn't really make sense does it?" 
      end

      @only = options[:only]
      @tables_to_exclude = (options[:except] || []) << 'schema_migrations'
    end

    def start
      # no-op
    end


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

  end

end


