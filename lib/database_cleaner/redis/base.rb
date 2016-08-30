require 'database_cleaner/generic/base'

module DatabaseCleaner
  module Redis
    def self.available_strategies
      %w{truncation}
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db ||= :default
      end

      alias url db

      private

      def connection
        @connection ||= begin
          if url == :default
            ::Redis.new
          elsif db.class.is_a?(::Redis) # pass directly the connection
            db
          else
            ::Redis.new(:url => url)
          end
        end
      end
    end
  end
end
