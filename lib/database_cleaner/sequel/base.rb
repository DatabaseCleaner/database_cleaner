require 'database_cleaner/generic/base'
module DatabaseCleaner
  module Sequel
    def self.available_strategies
      %w[truncation transaction]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        return @db if @db && @db != :unspecified
        if ::Sequel::DATABASES.count > 1
          raise ::DatabaseCleaner::UnspecifiedDatabase, "You have more than one active sequel database. You must specify which one to use!"
        end
        ::Sequel::DATABASES.first || :unspecified
      end
    end
  end
end
