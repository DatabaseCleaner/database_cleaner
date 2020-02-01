require "database_cleaner/ohm/version"
require "database_cleaner"
require "database_cleaner/ohm/truncation"

DatabaseCleaner.deprecate "The Ohm adapter for DatabaseCleaner is deprecated, and will be removed in v2.0. Please use the Redis adapter instead."

module DatabaseCleaner::Ohm
  def self.default_strategy
    :truncation
  end
end

