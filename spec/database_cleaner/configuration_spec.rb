require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'

describe DatabaseCleaner do
  before(:each) do
    DatabaseCleaner::ActiveRecord::Transaction.stub!(:new).and_return(@strategy = mock('strategy'))
    Object.const_set('ActiveRecord', "just mocking out the constant here...") unless defined?(::ActiveRecord)
    DatabaseCleaner.clear_strategy
  end

  describe ".strategy=" do
    it "should initialize the appropirate strategy based on the ORM adapter detected" do
      DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
      DatabaseCleaner.strategy = :transaction, {'options' => 'hash'}

      Object.send(:remove_const, 'ActiveRecord')
      Object.const_set('DataMapper', "just mocking out the constant here...")

      DatabaseCleaner::DataMapper::Transaction.should_receive(:new).with(no_args)
      DatabaseCleaner.strategy = :transaction
    end

    it "should raise an error when no ORM is detected" do
      Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
      Object.send(:remove_const, 'DataMapper') if defined?(::DataMapper)

      running { DatabaseCleaner.strategy = :transaction }.should raise_error(DatabaseCleaner::NoORMDetected)
    end

    it "should raise an error when the specified strategy is not found" do
      running { DatabaseCleaner.strategy = :foo }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
      running { DatabaseCleaner.strategy = Array }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
    end

  end


    %w[start clean].each do |strategy_method|
      describe ".#{strategy_method}" do
        it "should be delgated to the strategy set with strategy=" do
          DatabaseCleaner.strategy = :transaction

          @strategy.should_receive(strategy_method)

          DatabaseCleaner.send(strategy_method)
        end

        it "should raise en error when no strategy has been set" do
          running { DatabaseCleaner.send(strategy_method) }.should raise_error(DatabaseCleaner::NoStrategySetError)
        end
      end
    end
end
