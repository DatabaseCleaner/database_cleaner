require 'database_cleaner/redis/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module Redis
    class Truncation
      include ::DatabaseCleaner::Redis::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean(url = self.db)
        if url == :default
          redis = default_redis
        else
          redis = ::Redis.connect :url => url
        end
        if @only
          @only.each do |term|
            redis.keys(term).each { |k| redis.del k }
          end
        elsif @tables_to_exclude
          keys_except = []
          @tables_to_exclude.each { |term| keys_except += redis.keys(term) }
          redis.keys.each { |k| redis.del(k) unless keys_except.include?(k) }
        else
          redis.flushdb
        end
        redis.quit unless url == :default
      end

      private

      def default_redis
        ::Redis.connect
      end

    end
  end
end
