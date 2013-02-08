require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'active_record'

module DatabaseCleaner
  module ActiveRecord

    describe Transaction do
      let (:connection) { mock("connection") }
      before(:each) do
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      describe "#start" do
        it "should increment open transactions if possible" do
          connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(true)
          connection.stub!(:begin_db_transaction)

          connection.should_receive(:increment_open_transactions)
          Transaction.new.start
        end

        it "should tell ActiveRecord to increment connection if its not possible to increment current connection" do
          connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(false)
          connection.stub!(:begin_db_transaction)

          ::ActiveRecord::Base.should_receive(:increment_open_transactions)
          Transaction.new.start
        end

        it "should start a transaction" do
            connection.stub!(:increment_open_transactions)

            connection.should_receive(:begin_db_transaction)
            Transaction.new.start
        end
      end

      describe "#clean" do
        context "manual accounting of transaction count" do
          it "should start a transaction" do
            connection.should_receive(:open_transactions).and_return(1)

            connection.stub!(:decrement_open_transactions)

            connection.should_receive(:rollback_db_transaction)
            Transaction.new.clean
          end

          it "should decrement open transactions if possible" do
            connection.should_receive(:open_transactions).and_return(1)

            connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(true)
            connection.stub!(:respond_to?).with(:rollback_transaction_records).and_return(false)
            connection.stub!(:rollback_db_transaction)

            connection.should_receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should not try to decrement or rollback if open_transactions is 0 for whatever reason" do
            connection.should_receive(:open_transactions).and_return(0)

            Transaction.new.clean
          end

          it "should decrement connection via ActiveRecord::Base if connection won't" do
            connection.should_receive(:open_transactions).and_return(1)
            connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(false)
            connection.stub!(:respond_to?).with(:rollback_transaction_records).and_return(false)
            connection.stub!(:rollback_db_transaction)

            ::ActiveRecord::Base.should_receive(:decrement_open_transactions)
            Transaction.new.clean
          end
        end
        
        context "automatic accounting of transaction count" do

          it "should start a transaction" do
            stub_const("ActiveRecord::VERSION::MAJOR", 4)
            connection.stub!(:rollback_db_transaction)
            connection.should_receive(:open_transactions).and_return(1)

            connection.should_not_receive(:decrement_open_transactions)
            connection.should_receive(:rollback_db_transaction)
            Transaction.new.clean
          end

          it "should decrement open transactions if possible" do
            stub_const("ActiveRecord::VERSION::MAJOR", 4)
            connection.stub!(:rollback_db_transaction)
            connection.should_receive(:open_transactions).and_return(1)

            connection.should_not_receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should not try to decrement or rollback if open_transactions is 0 for whatever reason" do
            stub_const("ActiveRecord::VERSION::MAJOR", 4)
            connection.should_receive(:open_transactions).and_return(0)

            Transaction.new.clean
          end

          it "should decrement connection via ActiveRecord::Base if connection won't" do
            stub_const("ActiveRecord::VERSION::MAJOR", 4)
            connection.should_receive(:open_transactions).and_return(1)
            connection.stub!(:respond_to?).with(:rollback_transaction_records).and_return(false)
            connection.stub!(:rollback_db_transaction)

            ::ActiveRecord::Base.should_not_receive(:decrement_open_transactions)
            Transaction.new.clean
          end
        end
      end
      
      describe "#connection_maintains_transaction_count?" do
        it "should return true if the major active record version is < 4" do
          stub_const("ActiveRecord::VERSION::MAJOR", 3)
          Transaction.new.connection_maintains_transaction_count?.should be_true
        end
        it "should return false if the major active record version is > 3" do
          stub_const("ActiveRecord::VERSION::MAJOR", 4)
          Transaction.new.connection_maintains_transaction_count?.should be_false
        end
      end
      
    end
    
    

  end
end
