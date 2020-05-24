require "database_cleaner/mongoid/version"
require "database_cleaner"
require "database_cleaner/mongoid/truncation"
require "database_cleaner/mongoid/deletion"

module DatabaseCleaner::Mongoid
  def self.default_strategy
    :truncation
  end
end

