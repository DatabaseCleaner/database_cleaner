module DatabaseCleaner::ActiveRecord
  class Transaction

    def start
      connections = ActiveRecord::Base.connection_handler.connection_pools.values.map {|pool| pool.connection}

      connections.each do |connection|
        if connection.respond_to?(:increment_open_transactions)
          connection.increment_open_transactions
        else
          ActiveRecord::Base.__send__(:increment_open_transactions)
        end

        connection.begin_db_transaction
      end
    end


    def clean
      connections = ActiveRecord::Base.connection_handler.connection_pools.values.map {|pool| pool.connection}

      connections.each do |connection|
        connection.rollback_db_transaction

        if connection.respond_to?(:decrement_open_transactions)
          connection.decrement_open_transactions
        else
          ActiveRecord::Base.__send__(:decrement_open_transactions)
        end
      end
    end
  end

end
