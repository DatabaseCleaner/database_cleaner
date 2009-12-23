require 'database_cleaner/truncation_base'

module DatabaseCleaner
  module MongoMapper
    class Truncation < DatabaseCleaner::TruncationBase
      def clean
        connection.db(database).collections.each { |c| c.remove }
      end

      private

      def connection
        ::MongoMapper.connection
      end

      def database
        ::MongoMapper.database.name
      end
    end
  end
end
