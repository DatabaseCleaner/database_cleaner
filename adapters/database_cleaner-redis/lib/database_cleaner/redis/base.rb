require 'database_cleaner/generic/base'
require 'database_cleaner/deprecation'

module DatabaseCleaner
  module Redis
    def self.available_strategies
      %w{truncation deletion}
    end

    def self.default_strategy
      :truncation
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db ||= :default
      end

      def url
        DatabaseCleaner.deprecate "The redis deletion strategy's #url method is deprecated. It will be removed in database_cleaner-redis 2.0 in favor of #db."
        db
      end

      private

      def connection
        @connection ||= begin
          if url == :default
            ::Redis.new
          elsif db.is_a?(::Redis) # pass directly the connection
            db
          else
            ::Redis.new(:url => db)
          end
        end
      end
    end
  end
end
