module DatabaseCleaner::ActiveRecord
  class Transaction

    def start
      DatabaseCleaner::ActiveRecord.connection_klasses.each do |klass|
        if klass.connection.respond_to?(:increment_open_transactions)
          klass.connection.increment_open_transactions
        else
          klass.__send__(:increment_open_transactions)
        end

        klass.connection.begin_db_transaction
      end
    end


    def clean
      DatabaseCleaner::ActiveRecord.connection_klasses.each do |klass|
        klass.connection.rollback_db_transaction

        if klass.connection.respond_to?(:decrement_open_transactions)
          klass.connection.decrement_open_transactions
        else
          klass.__send__(:decrement_open_transactions)
        end
      end
    end
  end

end
