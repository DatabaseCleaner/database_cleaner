require 'database_cleaner/neo4j/base'
require 'neo4j-core'

module DatabaseCleaner
  module Neo4j
    class Deletion
      include ::DatabaseCleaner::Neo4j::Base

      def clean
        ::Neo4j::Transaction.run do
          session._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
        end
      end
    end
  end
end
