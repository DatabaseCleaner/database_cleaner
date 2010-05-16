require 'database_cleaner/generic/base'
module DatabaseCleaner
  module DataMapper
    def self.available_strategies
      %w[truncation transaction]
    end
    
    module Base
      include ::DatabaseCleaner::Generic::Base

      def connection_klass
        #TODO, multiple connections...
        raise NotImplementedError
        #::ActiveRecord::Base
      end
    end
  end
end