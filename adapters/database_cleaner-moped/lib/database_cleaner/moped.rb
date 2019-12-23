require "database_cleaner/moped/version"
require "database_cleaner"
require "database_cleaner/moped/truncation"

module DatabaseCleaner::Moped
  def self.default_strategy
    :truncation
  end
end

