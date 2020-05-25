require "database_cleaner/data_mapper/version"
require "database_cleaner"
require "database_cleaner/data_mapper/transaction"
require "database_cleaner/data_mapper/truncation"

DatabaseCleaner.deprecate "Due to lack of maintenance, the DataMapper adapter for DatabaseCleaner is deprecated, and will be removed in v2.0 with no replacement. Contact us if you are interested in resurrecting this adapter!"
