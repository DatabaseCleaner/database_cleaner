require 'database_cleaner/neo4j/base'
require 'neo4j-core'

module DatabaseCleaner
  module Neo4j
    class Deletion
      include ::DatabaseCleaner::Neo4j::Base

      def clean
        transaction do
          query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
        end
      end

      private

      def transaction(&block)
        if legacy_neo4j?
          ::Neo4j::Transaction.run(&block)
        else
          ::Neo4j::Transaction.run(session, &block)
        end
      end
    end
  end
end
