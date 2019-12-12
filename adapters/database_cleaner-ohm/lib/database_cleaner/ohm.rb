require "database_cleaner/ohm/version"
require "database_cleaner"
require "database_cleaner/ohm/truncation"

module DatabaseCleaner::Ohm
  def self.default_strategy
    :truncation
  end
end

