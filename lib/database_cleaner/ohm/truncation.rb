require 'database_cleaner/redis/truncation'

module DatabaseCleaner
  module Ohm
    def self.available_strategies
      %w(truncation)
    end

    class Truncation < ::DatabaseCleaner::Redis::Truncation

      private

      def default_redis
        ::Ohm.redis
      end

    end
  end
end
