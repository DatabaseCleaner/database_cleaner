require 'database_cleaner/sequel/base'
module DatabaseCleaner
  module Sequel
    class Transaction
      include ::DatabaseCleaner::Sequel::Base

      def start
        @transactions ||= []
        db.send(:add_transaction)
        @transactions << db.send(:begin_transaction, db)
      end
  
      def clean
        transaction = @transactions.pop
        db.send(:rollback_transaction, transaction)
        db.send(:remove_transaction, transaction)
      end
    end
  end
end
