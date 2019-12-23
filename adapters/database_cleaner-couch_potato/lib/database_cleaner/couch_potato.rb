require "database_cleaner/couch_potato/version"
require "database_cleaner"
require "database_cleaner/couch_potato/base"
require "database_cleaner/couch_potato/truncation"

module DatabaseCleaner::CouchPotato
  def self.default_strategy
    :truncation
  end
end

