require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'active_record'

module DatabaseCleaner
  module ActiveRecord

    describe Transaction do
      let (:connection) { double("connection") }
      let (:connection_2) { double("connection") }
      let (:connection_pool) { double("connection_pool")}
      before(:each) do
        allow(::ActiveRecord::Base).to receive(:connection_pool).and_return(connection_pool)
        allow(connection_pool).to receive(:connections).and_return([connection])
        allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
      end

      describe "#start" do
        [:begin_transaction, :begin_db_transaction].each do |begin_transaction_method|
          context "using #{begin_transaction_method}" do
            before do
              allow(connection).to receive(:transaction)
              allow(connection).to receive(begin_transaction_method)
            end

            it "should increment open transactions if possible" do
              expect(connection).to receive(:increment_open_transactions)
              Transaction.new.start
            end

            it "should tell ActiveRecord to increment connection if its not possible to increment current connection" do
              expect(::ActiveRecord::Base).to receive(:increment_open_transactions)
              Transaction.new.start
            end

            it "should start a transaction" do
              allow(connection).to receive(:increment_open_transactions)
              expect(connection).to receive(begin_transaction_method)
              expect(connection).to receive(:transaction)
              Transaction.new.start
            end
          end
        end
      end

      describe "#clean" do
        context "manual accounting of transaction count" do
          it "should start a transaction" do
            expect(connection).to receive(:open_transactions).and_return(1)

            allow(connection).to receive(:decrement_open_transactions)

            expect(connection).to receive(:rollback_db_transaction)
            Transaction.new.clean
          end

          it "should decrement open transactions if possible" do
            expect(connection).to receive(:open_transactions).and_return(1)

            allow(connection).to receive(:rollback_db_transaction)

            expect(connection).to receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should not try to decrement or rollback if open_transactions is 0 for whatever reason" do
            expect(connection).to receive(:open_transactions).and_return(0)

            Transaction.new.clean
          end

          it "should decrement connection via ActiveRecord::Base if connection won't" do
            expect(connection).to receive(:open_transactions).and_return(1)
            allow(connection).to receive(:rollback_db_transaction)

            expect(::ActiveRecord::Base).to receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should rollback open transactions in all connections" do
            allow(connection_pool).to receive(:connections).and_return([connection, connection_2])

            expect(connection).to receive(:open_transactions).and_return(1)
            allow(connection).to receive(:rollback_db_transaction)

            expect(connection_2).to receive(:open_transactions).and_return(1)
            allow(connection_2).to receive(:rollback_db_transaction)

            expect(::ActiveRecord::Base).to receive(:decrement_open_transactions).twice
            Transaction.new.clean
          end

          it "should rollback open transactions in all connections with an open transaction" do
            allow(connection_pool).to receive(:connections).and_return([connection, connection_2])

            expect(connection).to receive(:open_transactions).and_return(1)
            allow(connection).to receive(:rollback_db_transaction)

            expect(connection_2).to receive(:open_transactions).and_return(0)

            expect(::ActiveRecord::Base).to receive(:decrement_open_transactions).exactly(1).times
            Transaction.new.clean
          end
        end

        context "automatic accounting of transaction count (AR 4)" do
          before {stub_const("ActiveRecord::VERSION::MAJOR", 4) }

          it "should start a transaction" do
            allow(connection).to receive(:rollback_db_transaction)
            expect(connection).to receive(:open_transactions).and_return(1)

            expect(connection).not_to receive(:decrement_open_transactions)
            expect(connection).to receive(:rollback_transaction)
            Transaction.new.clean
          end

          it "should decrement open transactions if possible" do
            allow(connection).to receive(:rollback_transaction)
            expect(connection).to receive(:open_transactions).and_return(1)

            expect(connection).not_to receive(:decrement_open_transactions)
            Transaction.new.clean
          end

          it "should not try to decrement or rollback if open_transactions is 0 for whatever reason" do
            expect(connection).to receive(:open_transactions).and_return(0)

            Transaction.new.clean
          end

          it "should decrement connection via ActiveRecord::Base if connection won't" do
            expect(connection).to receive(:open_transactions).and_return(1)
            allow(connection).to receive(:rollback_transaction)

            expect(::ActiveRecord::Base).not_to receive(:decrement_open_transactions)
            Transaction.new.clean
          end
        end
      end

      describe "#connection_maintains_transaction_count?" do
        it "should return true if the major active record version is < 4" do
          stub_const("ActiveRecord::VERSION::MAJOR", 3)
          expect(Transaction.new.connection_maintains_transaction_count?).to be_truthy
        end
        it "should return false if the major active record version is > 3" do
          stub_const("ActiveRecord::VERSION::MAJOR", 4)
          expect(Transaction.new.connection_maintains_transaction_count?).to be_falsey
        end
      end

    end
  end
end
