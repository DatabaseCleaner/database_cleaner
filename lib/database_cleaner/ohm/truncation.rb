require 'database_cleaner/generic/truncation'
require 'database_cleaner/redis/truncation'

module DatabaseCleaner
  module Ohm
    class Truncation
      include ::DatabaseCleaner::Generic::Truncation
      include ::DatabaseCleaner::Redis::Truncation

      def database
        ::Ohm.redis
      end
    end
  end
end
