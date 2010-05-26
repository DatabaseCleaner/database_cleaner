require 'database_cleaner/generic/base'
module DatabaseCleaner
  module DataMapper
    def self.available_strategies
      %w[truncation transaction]
    end
    
    module Base
      include ::DatabaseCleaner::Generic::Base
    end
  end
end