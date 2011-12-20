require 'database_cleaner/generic/base'
require 'active_record'
require 'erb'

module DatabaseCleaner
  module ActiveRecord

    def self.available_strategies
      %w[truncation transaction deletion]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base

      def db=(model_class)
        @model_class = model_class unless model_class == :default # hack. this design sucks.
        @connection_class = nil
      end

      def db
        @model_class || ::ActiveRecord::Base
      end

      def connection
        connection_class.connection
      end

      def connection_class
        @connection_class ||=  db.is_a?(String) ? Module.const_get(db) : db
      end
    end
  end
end
