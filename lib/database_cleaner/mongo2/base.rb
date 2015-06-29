module DatabaseCleaner
  module Mongo2
    def self.available_strategies
      %w[truncation]
    end
    module Base
      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db || raise("You have not specified a database.  (see Mongo2::Database)")
      end
    end
  end
end
