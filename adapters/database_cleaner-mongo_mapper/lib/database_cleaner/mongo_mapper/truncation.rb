require 'database_cleaner/mongo_mapper/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module MongoMapper
    class Truncation
      include ::DatabaseCleaner::MongoMapper::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
        if @only
          collections.each { |c| c.send(truncate_method_name) if @only.include?(c.name) }
        else
          collections.each { |c| c.send(truncate_method_name) unless @tables_to_exclude.include?(c.name) }
        end
        true
      end

      private

      def collections
        database.collections.select { |c| c.name !~ /^system\./ }
      end

      def truncate_method_name
        # This constant only exists in the 2.x series.
        defined?(::Mongo::VERSION) ? :delete_many : :remove
      end

      def database
        ::MongoMapper.database
      end
    end
  end
end
