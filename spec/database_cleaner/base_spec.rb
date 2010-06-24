require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'

module DatabaseCleaner
  describe Base do
    
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
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :active_record
         cleaner.should be_auto_detected
       end

       it "should detect DataMapper second" do
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :data_mapper
         cleaner.should be_auto_detected
       end

       it "should detect MongoMapper third" do
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :mongo_mapper
         cleaner.should be_auto_detected
       end
       
       it "should detect Mongoid fourth" do
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :mongoid
         cleaner.should be_auto_detected
       end
       
       it "should detect CouchPotato last" do
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :couch_potato
         cleaner.should be_auto_detected
       end
    end
    
    describe "orm_module" do
      it "should ask ::DatabaseCleaner what the module is for its orm" do
        orm = mock("orm")
        mockule = mock("module")
        
        cleaner = ::DatabaseCleaner::Base.new
        cleaner.should_receive(:orm).and_return(orm)
        
        ::DatabaseCleaner.should_receive(:orm_module).with(orm).and_return(mockule)
        
        cleaner.send(:orm_module).should == mockule
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

    describe "strategy" do
      it "should raise NoStrategySetError if strategy is nil" do
        subject.instance_values[:strategy] = nil
        expect{ subject.strategy }.to raise_error NoStrategySetError
      end
      
      it "should return @strategy if @strategy is present" do
        strategum = mock("strategy")
        subject.strategy = strategum
        subject.strategy.should == strategum
      end
    end

    describe "initialization" do
      context "db specified" do
        subject { ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db) }
        
        it "should store db from :connection in params hash" do
          subject.db.should == :my_db          
        end
      end
     
      it "should test orm"
      
      it "should default to autodetect upon initalisation" do
        subject.should be_auto_detected
      end
    end
    
    describe "db" do
      it "should default to :default" do
        subject.db.should == :default
      end
      
      it "should return any stored db value" do
        subject.stub(:strategy_db=)
        subject.db = :test_db
        subject.db.should == :test_db
      end
      
      it "should pass db to any specified strategy" do
        subject.should_receive(:strategy_db=).with(:a_new_db)
        subject.db = :a_new_db
      end
    end
    
    describe "strategy_db=" do
      let(:strategy) { mock("strategy") }
      
      before(:each) do
        subject.strategy = strategy
      end

      it "should check that strategy supports db specification" do
        strategy.should_receive(:respond_to?).with(:db=).and_return(true)
        strategy.stub(:db=)
        subject.strategy_db = :a_db
      end
            
      context "when strategy supports db specification" do
        before(:each) { strategy.stub(:respond_to?).with(:db=).and_return true }
        
        it "should pass db to the strategy" do
          strategy.should_receive(:db=).with(:a_db)
          subject.strategy_db = :a_db
        end
      end                                                                       
      
      context "when strategy doesn't supports db specification" do
        before(:each) { strategy.stub(:respond_to?).with(:db=).and_return false }

        it "should check to see if db is :default" do
          db = mock("default")
          db.should_receive(:==).with(:default).and_return(true)

          subject.strategy_db = db
        end
        
        it "should raise an argument error when db isn't default" do
          db = mock("a db")
          expect{ subject.strategy_db = db }.to raise_error ArgumentError
        end
      end
    end
     
    describe "strategy=" do
      it "should proxy symbolised strategies to create_strategy" do
        subject.should_receive(:create_strategy).with(:symbol)
        subject.strategy = :symbol
      end
      
      it "should proxy params with symbolised strategies" do
        subject.should_receive(:create_strategy).with(:symbol,:param => "one")
        subject.strategy= :symbol, {:param => "one"}
      end
      
      it "should accept strategy objects" do
        expect{ subject.strategy = mock("strategy") }.to_not raise_error
      end
      
      it "should raise argument error when params given with strategy Object" do
        expect{ subject.strategy = mock("object"), {:param => "one"} }.to raise_error ArgumentError
      end
      
      it "should attempt to set strategy db" do
        subject.stub(:db).and_return(:my_db)
        subject.should_receive(:strategy_db=).with(:my_db)
        subject.strategy = mock("strategy")
      end
    end

    describe "clean_with" do
      let (:strategy) { mock("strategy",:clean => true) }
      
      before(:each) { subject.stub(:create_strategy).with(anything).and_return(strategy) }
      
      it "should pass all arguments to create_strategy" do
        subject.should_receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with :lorum, :dollar, :amet, { :ipsum => "random" }
      end
      
      it "should invoke clean on the created strategy" do
        strategy.should_receive(:clean)
        subject.clean_with :strategy
      end
      
      it "should return the strategy" do
        subject.clean_with( :strategy ).should == strategy
      end
    end
    
    describe "clean_with!" do
      let (:strategy) { mock("strategy",:clean => true) }
      
      before(:each) { subject.stub(:create_strategy).with(anything).and_return(strategy) }
      
      it "should pass all arguments to create_strategy" do
        subject.should_receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with! :lorum, :dollar, :amet, { :ipsum => "random" }
      end
      
      it "should invoke clean on the created strategy" do
        strategy.should_receive(:clean)
        subject.clean_with! :strategy
      end
      
      it "should return the strategy" do
        subject.clean_with!( :strategy ).should == strategy
      end
    end
                 
    describe "create_strategy" do
      it "should pass the first argument to orm_strategy" do
        subject.should_receive(:orm_strategy).with(:strategy).and_return(Object)
        subject.create_strategy :strategy
      end
      it "should pass the remainding argument to orm_strategy.new" do
        klass = mock("klass")
        klass.should_receive(:new).with(:params => {:lorum => "ipsum"})
        
        subject.stub(:orm_strategy).and_return(klass)
        subject.create_strategy :strategy, {:params => {:lorum => "ipsum"}}
      end
      it "should return the resulting strategy" do

      end
    end
    
    describe "orm integration" do
      let(:strategy) { mock("stratagem, attack all robots") }

      context "active record" do
        let(:cleaner)  { ::DatabaseCleaner::Base.new(:active_record) }

        before(:each) do
          ::DatabaseCleaner::ActiveRecord::Transaction.stub!(:new).and_return(strategy)
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
