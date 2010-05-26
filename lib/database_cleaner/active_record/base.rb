require 'database_cleaner/generic/base'
require 'active_record'

module DatabaseCleaner
  module ActiveRecord
    
    def self.available_strategies
      %w[truncation transaction]
    end
    
    module Base
      include ::DatabaseCleaner::Generic::Base

      def connection_klass
        #TODO, multiple connections...
        ::ActiveRecord::Base
      end
    end
  end
end