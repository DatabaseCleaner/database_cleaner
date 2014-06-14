require 'database_cleaner/generic/base'

module DatabaseCleaner
  module Redic
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
        @connection ||= url == :default ? ::Redic.new : ::Redic.new(url)
      end

    end
  end
end
