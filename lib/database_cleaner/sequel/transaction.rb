require 'database_cleaner/sequel/base'
module DatabaseCleaner
  module Sequel
    class Transaction
      include ::DatabaseCleaner::Sequel::Base

      def start
        @transactions ||= []
        opts= {:savepoint => true}
        db.send(:add_transaction, db, opts)
        db.send(:begin_transaction, db, opts)
        @transactions << db
      end

      def clean
        db= @transactions.pop
        db.send(:rollback_transaction, db)
        db.send(:remove_transaction, db, false)
      end
    end
  end
end
