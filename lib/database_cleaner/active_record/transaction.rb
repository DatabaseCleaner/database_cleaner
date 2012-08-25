require 'database_cleaner/active_record/base'
require 'database_cleaner/generic/transaction'

module DatabaseCleaner::ActiveRecord
  class Transaction
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Transaction

    def start
      if connection_class.connection.respond_to?(:increment_open_transactions)
        connection_class.connection.increment_open_transactions
      else
        connection_class.__send__(:increment_open_transactions)
      end
      connection_class.connection.begin_db_transaction
    end


    def clean
      return unless connection_class.connection.open_transactions > 0

      connection_class.connection.rollback_db_transaction

      if connection_class.connection.respond_to?(:decrement_open_transactions)
        connection_class.connection.decrement_open_transactions
      else
        connection_class.__send__(:decrement_open_transactions)
      end
    end
  end
end
