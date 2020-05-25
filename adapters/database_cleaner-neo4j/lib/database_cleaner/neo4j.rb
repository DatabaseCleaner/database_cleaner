require "database_cleaner/neo4j/version"
require "database_cleaner"
require "database_cleaner/neo4j/transaction"
require "database_cleaner/neo4j/truncation"
require "database_cleaner/neo4j/deletion"

DatabaseCleaner.deprecate "Due to lack of maintenance, the Neo4j adapter for DatabaseCleaner is deprecated, and will be removed in v2.0 with no replacement. Contact us if you are interested in resurrecting this adapter!"
