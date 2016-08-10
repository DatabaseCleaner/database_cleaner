require 'database_cleaner/neo4j/base'
require 'database_cleaner/generic/transaction'
require 'neo4j-core'

module DatabaseCleaner
  module Neo4j
    class Transaction
      include ::DatabaseCleaner::Generic::Transaction
      include ::DatabaseCleaner::Neo4j::Base

      attr_accessor :tx

      def start
        super
        rollback
        self.tx = new_transaction
      end

      def clean
        rollback
      end

      private

      def rollback
        if tx
          tx.failure
          tx.close
        end
      ensure
        self.tx = nil
      end

      def new_transaction
        legacy_neo4j? ? ::Neo4j::Transaction.new : ::Neo4j::Transaction.new(session)
      end
    end
  end
end
