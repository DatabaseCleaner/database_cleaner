begin # when database_cleaner-ohm is loaded as a gem
  require 'database_cleaner/redis/truncation'
rescue LoadError # when database_cleaner is loaded as a gem
  $LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../../../../../adapters/database_cleaner-redis/lib")
  require 'database_cleaner/redis/truncation'
end

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
