require 'database_cleaner/generic/base'

module DatabaseCleaner
  module Redis
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

      def cluster_mode=(flag)
        @cluster_mode = flag
      end

      def cluster_mode
        @cluster_mode ||= false
      end

      alias url db

      private

      def connection
        @connection ||= begin
          if url == :default
            ::Redis.new
          elsif db.is_a?(::Redis) # pass directly the connection
            db
          else
            ::Redis.new(:url => url)
          end
        end
      end
    end
  end
end
