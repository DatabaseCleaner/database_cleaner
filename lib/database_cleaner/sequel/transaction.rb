require 'database_cleaner/sequel/base'
module DatabaseCleaner
  module Sequel
    class Transaction
      include ::DatabaseCleaner::Sequel::Base

      def start
        db.begin_transaction
      end
  
      def clean
        db.rollback_transaction
      end
    end
  end
end
