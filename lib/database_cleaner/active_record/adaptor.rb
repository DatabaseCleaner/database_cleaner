require 'database_cleaner/strategy_base'

module DatabaseCleaner
  module ActiveRecord
    def self.available_strategies
      %w[truncation transaction]
    end
    
    module Adaptor
      include ::DatabaseCleaner::StrategyBase
      
      def connection_klass
        ::ActiveRecord::Base
      end
    end
  end
end