require 'database_cleaner/mongo_mapper/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'

module DatabaseCleaner
  module MongoMapper
    class Truncation
      include ::DatabaseCleaner::MongoMapper::Base
      include ::DatabaseCleaner::Generic::Truncation
      include ::DatabaseCleaner::Mongo::TruncationMixin
      
      private

      def database
        ::MongoMapper.database
      end
    end
  end
end
