require 'database_cleaner/generic/base'
module DatabaseCleaner
  module MongoMapper
    def self.available_strategies
      %w[truncation]
    end
    
    module Base
      include ::DatabaseCleaner::Generic::Base
    end
  end
end