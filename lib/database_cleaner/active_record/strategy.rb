require 'database_cleaner/generic/strategy'

module DatabaseCleaner
  module ActiveRecord
    
    def self.available_strategies
      %w[truncation transaction]
    end
    
    module Strategy
      include ::DatabaseCleaner::Generic::Strategy

      def connection_klass
        #TODO, multiple connections...
        #::ActiveRecord::Base
      end
    end
  end
end