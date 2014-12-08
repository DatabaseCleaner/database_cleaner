require 'database_cleaner/generic/base'
module DatabaseCleaner
  module Neo4j
    def self.available_strategies
      %w[transaction truncation deletion]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db == :default ? nil : desired_db
      end

      def db
        @db ||= nil
      end

      def start
        if db_type == :embedded_db and not session.running?
          session.start
        else
          session
        end
      end

      def database
        db && default_db.merge(db) || default_db
      end

      private

      def default_db
        {:type => default_db_type, :path => default_db_path}
      end

      def default_db_type
        :server_db
      end

      def default_db_path(type = default_db_type)
        type == :server_db ? 'http://localhost:7475/' : './db/test'
      end

      def db_type
        database[:type]
      end

      def db_path
        database[:path]
      end

      def session
        @session ||= ::Neo4j::Session.open(db_type, db_path)
      end
    end
  end
end
