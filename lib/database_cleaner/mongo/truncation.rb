require 'database_cleaner/mongo/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'
module DatabaseCleaner
  module Mongo
    class Truncation
      include ::DatabaseCleaner::Generic::Truncation
      include TruncationMixin
      private

      def database
        ::Mongo.connection
      end
    end
  end
end
