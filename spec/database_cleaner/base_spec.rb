require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'

module DatabaseCleaner
  describe Base do

    #this could do with a better assertion
    it "should default to autodetect upon initalisation" do
      cleaner = ::DatabaseCleaner::Base.new
      cleaner.auto_detected.should == true
    end

    describe "autodetect" do

       #Cache all ORMs, we'll need them later but not now.
       before(:all) do
         Temp_AR = ::ActiveRecord if defined?(::ActiveRecord) and not defined?(Temp_AR)
         Temp_DM = ::DataMapper   if defined?(::DataMapper)   and not defined?(Temp_DM)
         Temp_MM = ::MongoMapper  if defined?(::MongoMapper)  and not defined?(Temp_MM)
         Temp_MO = ::Mongoid      if defined?(::Mongoid)      and not defined?(Temp_MO)
         Temp_CP = ::CouchPotato  if defined?(::CouchPotato)  and not defined?(Temp_CP)
       end

       #Remove all ORM mocks and restore from cache
       after(:all) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
         
         
         # Restore ORMs
         ::ActiveRecord = Temp_AR if defined? Temp_AR
         ::DataMapper   = Temp_DM if defined? Temp_DM
         ::MongoMapper  = Temp_MM if defined? Temp_MM
         ::Mongoid      = Temp_MO if defined? Temp_MO
         ::CouchPotato  = Temp_CP if defined? Temp_CP
       end

       #reset the orm mocks
       before(:each) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
       end

       let(:cleaner) { DatabaseCleaner::Base.new :autodetect }

       it "should raise an error when no ORM is detected" do
         running { cleaner }.should raise_error(DatabaseCleaner::NoORMDetected)
       end

       it "should detect ActiveRecord first" do
         Object.const_set('ActiveRecord','Actively mocking records.')
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :active_record
       end

       it "should detect DataMapper second" do
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :data_mapper
       end

       it "should detect MongoMapper third" do
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :mongo_mapper
       end

       it "should detect CouchPotato last" do
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :couch_potato
       end
    end

    describe "comparison" do
      it "should be equal if orm, connection and strategy are the same" do
        strategy = mock("strategy")

        one = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        one.strategy = strategy

        two = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        two.strategy = strategy

        one.should == two
        two.should == one
      end
    end

    describe "db specification" do
      it "should choose the default connection if none is specified" do
        base = ::DatabaseCleaner::Base.new(:active_record)
        base.db.should == :default
      end

      it "should accept connection as part of a hash of options" do
        base = ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db)
        base.db.should == :my_db
      end

      it "should check to see if strategy supports db specification" do
        strategy = mock("strategy",:db= => :my_db)
        strategy.stub(:respond_to?).with(anything)
        strategy.should_receive(:respond_to?).with(:db=).and_return(true)
        ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db).strategy = strategy
      end

      it "should pass db through to the strategy" do
        strategy = mock("strategy")

        strategy.stub(:respond_to?).with(anything)
        strategy.stub(:respond_to?).with(:db=).and_return(true)

        strategy.should_receive(:db=).with(:my_db)
        ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db).strategy = strategy
      end

      it "should raise ArgumentError if db isn't default and strategy doesn't support different dbs" do
        strategy = mock("strategy")

        strategy.stub(:respond_to?).with(anything)
        strategy.stub(:respond_to?).with(:db=).and_return(false)

        expect { ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db).strategy = strategy }.to raise_error(ArgumentError)
      end
    end

    describe "orm integration" do
      let(:strategy) { mock("stratagem, attack all robots") }

      context "active record" do
        let(:cleaner)  { ::DatabaseCleaner::Base.new(:active_record) }

        before(:each) do
          ::DatabaseCleaner::ActiveRecord::Transaction.stub!(:new).and_return(strategy)
          #Object.const_set('ActiveRecord', "just mocking out the constant here...") unless defined?(::ActiveRecord)
          cleaner.strategy = nil
        end

        describe ".create_strategy" do
          it "should initialize and return the appropriate strategy" do
            DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
            result = cleaner.create_strategy(:transaction, {'options' => 'hash'})
            result.should == strategy
          end
        end

        describe ".clean_with" do
          it "should initialize the appropirate strategy and clean with it" do
            DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
            strategy.should_receive(:clean)
            cleaner.clean_with(:transaction, 'options' => 'hash')
          end
        end

        describe ".strategy=" do
          it "should initialize the appropirate strategy for active record" do
            DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
            cleaner.strategy = :transaction, {'options' => 'hash'}
          end

          it "should allow any object to be set as the strategy" do
            mock_strategy = mock('strategy')
            running { DatabaseCleaner.strategy = mock_strategy }.should_not raise_error
          end

          it "should raise an error when the specified strategy is not found" do
            running { DatabaseCleaner.strategy = :foo }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
          end

          it "should raise an error when multiple args is passed in and the first is not a symbol" do
            running { DatabaseCleaner.strategy=Object.new, {:foo => 'bar'} }.should raise_error(ArgumentError)
          end
        end

        %w[start clean].each do |strategy_method|
          describe ".#{strategy_method}" do
            it "should be delgated to the strategy set with strategy=" do
              cleaner.strategy = :transaction

              strategy.should_receive(strategy_method)

              cleaner.send(strategy_method)
            end

            it "should raise en error when no strategy has been set" do
              running { cleaner.send(strategy_method) }.should raise_error(DatabaseCleaner::NoStrategySetError)
            end
          end
        end
      end

      context "data mapper" do
        let(:cleaner)  { ::DatabaseCleaner::Base.new(:data_mapper) }

        before(:each) do
          ::DatabaseCleaner::DataMapper::Transaction.stub!(:new).and_return(strategy)
          cleaner.strategy = nil
        end

        describe ".create_strategy" do
          it "should initialize and return the appropirate strategy" do
            DatabaseCleaner::DataMapper::Transaction.should_receive(:new)
            result = cleaner.create_strategy(:transaction)
            result.should == strategy
          end
        end

        describe ".clean_with" do
          it "should initialize the appropirate strategy and clean with it" do
            DatabaseCleaner::DataMapper::Transaction.should_receive(:new)
            strategy.should_receive(:clean)
            cleaner.clean_with(:transaction)
          end
        end

        describe ".strategy=" do
          it "should initalize the appropriate strategy for data mapper" do
            DatabaseCleaner::DataMapper::Transaction.should_receive(:new).with(no_args)
            cleaner.strategy = :transaction
          end

          it "should allow any object to be set as the strategy" do
            mock_strategy = mock('strategy')
            running { cleaner.strategy = mock_strategy }.should_not raise_error
          end

          it "should raise an error when the specified strategy is not found" do
            running { cleaner.strategy = :foo }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
          end

          it "should raise an error when multiple args is passed in and the first is not a symbol" do
            running { cleaner.strategy=Object.new, {:foo => 'bar'} }.should raise_error(ArgumentError)
          end
        end

        %w[start clean].each do |strategy_method|
          describe ".#{strategy_method}" do
            it "should be delgated to the strategy set with strategy=" do
              cleaner.strategy = :transaction

              strategy.should_receive(strategy_method)

              cleaner.send(strategy_method)
            end

            it "should raise en error when no strategy has been set" do
              running { cleaner.send(strategy_method) }.should raise_error(DatabaseCleaner::NoStrategySetError)
            end
          end
        end
      end
    end
  end
end
