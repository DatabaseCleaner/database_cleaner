require 'database_cleaner/active_record/base'
module DatabaseCleaner::ActiveRecord
  class Transaction
    include ::DatabaseCleaner::ActiveRecord::Base

    def start
      if connection.respond_to?(:increment_open_transactions)
        connection.increment_open_transactions
      else
        connection_class.__send__(:increment_open_transactions)
      end
      connection.begin_db_transaction
    end


    def clean
      return unless connection.open_transactions > 0

      connection.rollback_db_transaction

      if connection.respond_to?(:decrement_open_transactions)
        connection.decrement_open_transactions
      else
        connection_class.__send__(:decrement_open_transactions)
      end
    end
  end
end
