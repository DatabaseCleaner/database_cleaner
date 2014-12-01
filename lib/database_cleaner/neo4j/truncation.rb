require 'database_cleaner/neo4j/base'
require 'database_cleaner/neo4j/deletion'

module DatabaseCleaner
  module Neo4j
    class Truncation < DatabaseCleaner::Neo4j::Deletion
    end
  end
end
