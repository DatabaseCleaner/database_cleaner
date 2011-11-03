require 'database_cleaner/generic/base'
module DatabaseCleaner
  module Mongoid
    def self.available_strategies
      %w[truncation]
    end

    module Base
      include ::DatabaseCleaner::Generic::Base
      include ::DatabaseCleaner::Generic::ConfigurableDB
    end
  end
end
