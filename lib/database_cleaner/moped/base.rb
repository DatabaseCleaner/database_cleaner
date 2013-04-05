require 'database_cleaner/generic/base'

module DatabaseCleaner
  module Moped
    def self.available_strategies
      %w[truncation]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db || :default
      end

      def host_port=(desired_host)
        @host = desired_host
      end

      def host
        @host || '127.0.0.1:27017'
      end

      private

      def session
        ::Moped::Session.new([host], database: db)
      end
    end
  end
end
