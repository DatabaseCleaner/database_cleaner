require 'database_cleaner/mongo/base'
require 'database_cleaner/generic/truncation'
require 'database_cleaner/mongo/truncation_mixin'
module DatabaseCleaner
  module Mongo
    class Truncation
      include ::DatabaseCleaner::Generic::Truncation
      include TruncationMixin
      include Base
      private

      def database
        db
      end
    end
  end
end
