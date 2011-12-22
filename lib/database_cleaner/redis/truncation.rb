module DatabaseCleaner
  module Redis
    module Truncation

      def clean(url = self.db)
        if url == :default
          redis = ::Ohm.redis
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

    end
  end
end
