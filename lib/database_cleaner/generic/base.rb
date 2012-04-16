require 'active_record'
require 'database_cleaner/active_record/base'
require 'erb'

module DatabaseCleaner
  module ActiveRecord

    def self.available_strategies
      %w[truncation transaction deletion surgicalstrike]
    end
  end
end
