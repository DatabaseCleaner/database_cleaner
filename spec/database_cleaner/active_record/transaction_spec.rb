require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'active_record'

module DatabaseCleaner
  module ActiveRecord

    describe Transaction do
      let (:connection) { mock("connection") }
      let (:another_connection) { mock("a different connection") }
    
      let (:model_klass) do
        model_klass = mock("klass")
        model_klass.stub!(:connection).and_return(another_connection)
        model_klass
      end

      before(:each) do
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      describe "start" do
        context "single connection" do
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
        
        context "multiple connection" do

          it "should has specs?"
          # before(:each) do            
          #   DatabaseCleaner::ActiveRecord.connection_klasses = [model_klass]
          # end
          # 
          # after(:each) do
          #   DatabaseCleaner::ActiveRecord.connection_klasses = []
          # end
          # 
          # it "should increment open transactions on both connections if possible" do
          #   connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(true)
          #   connection.stub!(:begin_db_transaction)
          # 
          #   another_connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(true)
          #   another_connection.stub!(:begin_db_transaction)
          #   
          #   connection.should_receive(:increment_open_transactions)          
          #   another_connection.should_receive(:increment_open_transactions)
          #   Transaction.new.start
          # end
          #         
          # it "should tell ActiveRecord to increment connection if its not possible to increment current connection" do
          #   connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(false)
          #   connection.stub!(:begin_db_transaction)
          # 
          #   another_connection.stub!(:respond_to?).with(:increment_open_transactions).and_return(false)
          #   another_connection.stub!(:begin_db_transaction)
          # 
          #   ::ActiveRecord::Base.should_receive(:increment_open_transactions)
          #   model_klass.should_receive(:increment_open_transactions)
          #   Transaction.new.start
          # end
          #         
          # it "should start a transaction" do
          #     connection.stub!(:increment_open_transactions)
          #     another_connection.stub!(:increment_open_transactions)
          #   
          #     connection.should_receive(:begin_db_transaction)
          #     another_connection.should_receive(:begin_db_transaction)
          #     Transaction.new.start
          # end
        end
      end
      
      describe "clean" do
        context "single connection" do
          it "should finish a transaction" do
              connection.stub!(:decrement_open_transactions)

              connection.should_receive(:rollback_db_transaction)
              Transaction.new.clean
          end
          
          it "should decrement open transactions if possible" do
            connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(true)
            connection.stub!(:rollback_db_transaction)

            connection.should_receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should decrement connection via ActiveRecord::Base if connection won't" do
            connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(false)
            connection.stub!(:rollback_db_transaction)

            ::ActiveRecord::Base.should_receive(:decrement_open_transactions)
            Transaction.new.clean
          end
        end
        
        context "multiple connection" do
          it "should has specs?"
          # before(:each) do            
          #   DatabaseCleaner::ActiveRecord.connection_klasses = [model_klass]
          # end
          # 
          # after(:each) do
          #   DatabaseCleaner::ActiveRecord.connection_klasses = []
          # end
          # 
          # it "should finish a transaction" do
          #     connection.stub!(:decrement_open_transactions)
          #     another_connection.stub!(:decrement_open_transactions)
          #     
          #     connection.should_receive(:rollback_db_transaction)
          #     another_connection.should_receive(:rollback_db_transaction)
          #     Transaction.new.clean
          # end
          # 
          # it "should decrement open transactions if possible" do
          #   connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(true)
          #   connection.stub!(:rollback_db_transaction)
          # 
          #   another_connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(true)
          #   another_connection.stub!(:rollback_db_transaction)
          # 
          #   connection.should_receive(:decrement_open_transactions)
          #   another_connection.should_receive(:decrement_open_transactions)
          #   Transaction.new.clean
          # end
          # 
          # it "should decrement connection via ActiveRecord::Base if connection won't" do
          #   connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(false)
          #   connection.stub!(:rollback_db_transaction)
          #   
          #   another_connection.stub!(:respond_to?).with(:decrement_open_transactions).and_return(false)
          #   another_connection.stub!(:rollback_db_transaction)
          # 
          #   ::ActiveRecord::Base.should_receive(:decrement_open_transactions)
          #   model_klass.should_receive(:decrement_open_transactions)
          #   Transaction.new.clean
          # end 
        end
      end
    end

  end
end
