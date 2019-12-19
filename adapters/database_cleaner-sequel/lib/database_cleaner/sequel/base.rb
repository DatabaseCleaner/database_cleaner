require 'database_cleaner/generic/base'
module DatabaseCleaner
  module Sequel
    def self.available_strategies
      %w(truncation transaction deletion)
    end

    def self.default_strategy
      :transaction
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(desired_db)
        @db = desired_db
      end

      def db
        return @db if @db && @db != :default
        raise "As you have more than one active sequel database you have to specify the one to use manually!" if ::Sequel::DATABASES.count > 1
        ::Sequel::DATABASES.first || :default
      end
    end
  end
end
