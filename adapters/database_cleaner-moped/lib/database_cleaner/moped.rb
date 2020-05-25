require "database_cleaner/moped/version"
require "database_cleaner"
require "database_cleaner/moped/truncation"

DatabaseCleaner.deprecate "Due to lack of maintenance, the Moped adapter for DatabaseCleaner is deprecated, and will be removed in v2.0 with no replacement. Contact us if you are interested in resurrecting this adapter!"

module DatabaseCleaner::Moped
  def self.default_strategy
    :truncation
  end
end

