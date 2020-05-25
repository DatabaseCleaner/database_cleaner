require "database_cleaner/couch_potato/version"
require "database_cleaner"
require "database_cleaner/couch_potato/base"
require "database_cleaner/couch_potato/truncation"

DatabaseCleaner.deprecate "Due to lack of maintenance, the Couch Potato adapter for DatabaseCleaner is deprecated, and will be removed in v2.0 with no replacement. Contact us if you are interested in resurrecting this adapter!"

module DatabaseCleaner::CouchPotato
  def self.default_strategy
    :truncation
  end
end

