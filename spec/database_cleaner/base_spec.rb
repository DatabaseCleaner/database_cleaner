require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'
require 'database_cleaner/mongo_mapper/truncation'
require 'database_cleaner/mongoid/truncation'
require 'database_cleaner/couch_potato/truncation'
require 'database_cleaner/neo4j/transaction'

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
         Temp_SQ = ::Sequel       if defined?(::Sequel)       and not defined?(Temp_SQ)
         Temp_MP = ::Moped        if defined?(::Moped)        and not defined?(Temp_MP)
         Temp_RS = ::Redis        if defined?(::Redis)        and not defined?(Temp_RS)
         Temp_OH = ::Ohm          if defined?(::Ohm)          and not defined?(Temp_OH)
         Temp_NJ = ::Neo4j        if defined?(::Neo4j)        and not defined?(Temp_NJ)
       end

       #Remove all ORM mocks and restore from cache
       after(:all) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
         Object.send(:remove_const, 'Sequel')       if defined?(::Sequel)
         Object.send(:remove_const, 'Moped')        if defined?(::Moped)
         Object.send(:remove_const, 'Ohm')          if defined?(::Ohm)
         Object.send(:remove_const, 'Redis')        if defined?(::Redis)
         Object.send(:remove_const, 'Neo4j')        if defined?(::Neo4j)


         # Restore ORMs
         ::ActiveRecord = Temp_AR if defined? Temp_AR
         ::DataMapper   = Temp_DM if defined? Temp_DM
         ::MongoMapper  = Temp_MM if defined? Temp_MM
         ::Mongoid      = Temp_MO if defined? Temp_MO
         ::CouchPotato  = Temp_CP if defined? Temp_CP
         ::Sequel       = Temp_SQ if defined? Temp_SQ
         ::Moped        = Temp_MP if defined? Temp_MP
         ::Ohm          = Temp_OH if defined? Temp_OH
         ::Redis        = Temp_RS if defined? Temp_RS
         ::Neo4j        = Temp_NJ if defined? Temp_NJ
       end

       #reset the orm mocks
       before(:each) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
         Object.send(:remove_const, 'Sequel')       if defined?(::Sequel)
         Object.send(:remove_const, 'Moped')        if defined?(::Moped)
         Object.send(:remove_const, 'Ohm')          if defined?(::Ohm)
         Object.send(:remove_const, 'Redis')        if defined?(::Redis)
         Object.send(:remove_const, 'Neo4j')        if defined?(::Neo4j)
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
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         cleaner.orm.should eq :active_record
         cleaner.should be_auto_detected
       end

       it "should detect DataMapper second" do
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         cleaner.orm.should eq :data_mapper
         cleaner.should be_auto_detected
       end

       it "should detect MongoMapper third" do
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         cleaner.orm.should eq :mongo_mapper
         cleaner.should be_auto_detected
       end

       it "should detect Mongoid fourth" do
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         cleaner.orm.should eq :mongoid
         cleaner.should be_auto_detected
       end

       it "should detect CouchPotato fifth" do
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         cleaner.orm.should eq :couch_potato
         cleaner.should be_auto_detected
       end

       it "should detect Sequel sixth" do
         Object.const_set('Sequel', 'Sequel mock')
         Object.const_set('Moped',  'Moped mock')
         Object.const_set('Ohm',    'Ohm mock')
         Object.const_set('Redis',  'Redis mock')
         Object.const_set('Neo4j',  'Neo4j mock')

         cleaner.orm.should eq :sequel
         cleaner.should be_auto_detected
       end

       it 'detects Moped seventh' do
         Object.const_set('Moped', 'Moped mock')

         cleaner.orm.should eq :moped
         cleaner.should be_auto_detected
       end

       it 'detects Ohm eighth' do
         Object.const_set('Ohm',    'Ohm mock')
         Object.const_set('Redis',  'Redis mock')
         Object.const_set('Neo4j',  'Neo4j mock')

         cleaner.orm.should eq :ohm
         cleaner.should be_auto_detected
       end

       it 'detects Redis ninth' do
         Object.const_set('Redis', 'Redis mock')
         Object.const_set('Neo4j', 'Neo4j mock')

         cleaner.orm.should eq :redis
         cleaner.should be_auto_detected
       end

       it 'detects Neo4j tenth' do
         Object.const_set('Neo4j', 'Neo4j mock')

         cleaner.orm.should eq :neo4j
         cleaner.should be_auto_detected
       end
    end

    describe "orm_module" do
      it "should ask ::DatabaseCleaner what the module is for its orm" do
        orm = double("orm")
        mockule = double("module")

        cleaner = ::DatabaseCleaner::Base.new
        cleaner.should_receive(:orm).and_return(orm)

        ::DatabaseCleaner.should_receive(:orm_module).with(orm).and_return(mockule)

        cleaner.send(:orm_module).should eq mockule
      end
    end

    describe "comparison" do
      it "should be equal if orm, connection and strategy are the same" do
        strategy = mock("strategy")
        strategy.stub!(:to_ary => [strategy])

        one = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        one.strategy = strategy

        two = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        two.strategy = strategy

        one.should eq two
        two.should eq one
      end
    end

    describe "initialization" do
      context "db specified" do
        subject { ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db) }

        it "should store db from :connection in params hash" do
          subject.db.should eq :my_db
        end
      end

      describe "orm" do
        it "should store orm" do
          cleaner = ::DatabaseCleaner::Base.new :a_orm
          cleaner.orm.should eq :a_orm
        end

        it "converts string to symbols" do
          cleaner = ::DatabaseCleaner::Base.new "mongoid"
          cleaner.orm.should eq :mongoid
        end

        it "is autodetected if orm is not provided" do
          cleaner = ::DatabaseCleaner::Base.new
          cleaner.should be_auto_detected
        end

        it "is autodetected if you specify :autodetect" do
          cleaner = ::DatabaseCleaner::Base.new "autodetect"
          cleaner.should be_auto_detected
        end

        it "should default to autodetect upon initalisation" do
          subject.should be_auto_detected
        end
      end
    end

    describe "db" do
      it "should default to :default" do
        subject.db.should eq :default
      end

      it "should return any stored db value" do
        subject.stub(:strategy_db=)
        subject.db = :test_db
        subject.db.should eq :test_db
      end

      it "should pass db to any specified strategy" do
        subject.should_receive(:strategy_db=).with(:a_new_db)
        subject.db = :a_new_db
      end
    end

    describe "strategy_db=" do
      let(:strategy) {
        mock("strategy").tap{|strategy|
          strategy.stub!(:to_ary => [strategy])
        }
      }

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
          db = double("default")
          db.should_receive(:==).with(:default).and_return(true)

          subject.strategy_db = db
        end

        it "should raise an argument error when db isn't default" do
          db = double("a db")
          expect{ subject.strategy_db = db }.to raise_error ArgumentError
        end
      end
    end

    describe "clean_with" do
      let (:strategy) { double("strategy",:clean => true) }

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
        subject.clean_with( :strategy ).should eq strategy
      end
    end

    describe "clean_with!" do
      let (:strategy) { double("strategy",:clean => true) }

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
        subject.clean_with!( :strategy ).should eq strategy
      end
    end

    describe "create_strategy" do
      let(:strategy_class) { double("strategy_class",:new => double("instance")) }

      before :each do
        subject.stub(:orm_strategy).and_return(strategy_class)
      end

      it "should pass the first argument to orm_strategy" do
        subject.should_receive(:orm_strategy).with(:strategy).and_return(Object)
        subject.create_strategy :strategy
      end
      it "should pass the remainding argument to orm_strategy.new" do
        strategy_class.should_receive(:new).with(:params => {:lorum => "ipsum"})

        subject.create_strategy :strategy, {:params => {:lorum => "ipsum"}}
      end
      it "should return the resulting strategy" do
        subject.create_strategy( :strategy ).should eq strategy_class.new
      end
    end

    describe "strategy=" do
      let(:mock_strategy) {
        mock("strategy").tap{|strategy|
        strategy.stub!(:to_ary => [strategy])
      }
      }

      it "should proxy symbolised strategies to create_strategy" do
        subject.should_receive(:create_strategy).with(:symbol)
        subject.strategy = :symbol
      end

      it "should proxy params with symbolised strategies" do
        subject.should_receive(:create_strategy).with(:symbol,:param => "one")
        subject.strategy= :symbol, {:param => "one"}
      end

      it "should accept strategy objects" do
        expect{ subject.strategy = mock_strategy }.to_not raise_error
      end

      it "should raise argument error when params given with strategy Object" do
        expect{ subject.strategy = double("object"), {:param => "one"} }.to raise_error ArgumentError
      end

      it "should attempt to set strategy db" do
        subject.stub(:db).and_return(:my_db)
        subject.should_receive(:set_strategy_db).with(mock_strategy, :my_db)
        subject.strategy = mock_strategy
      end

      it "should return the stored strategy" do
        result = subject.strategy = mock_strategy
        result.should eq mock_strategy
      end
    end

    describe "strategy" do
      subject { ::DatabaseCleaner::Base.new :a_orm }

      it "returns a null strategy when strategy is not set and undetectable" do
        subject.strategy.should eq DatabaseCleaner::NullStrategy
      end

      it "returns the set strategy" do
        strategum = mock("strategy").tap{|strategy|
          strategy.stub!(:to_ary => [strategy])
        }
        subject.strategy = strategum
        subject.strategy.should eq strategum
      end
    end

    describe "orm=" do
      it "should stored the desired orm" do
        subject.orm.should_not eq :desired_orm
        subject.orm = :desired_orm
        subject.orm.should eq :desired_orm
      end
    end

    describe "orm" do
      let(:mock_orm) { double("orm") }

      it "should return orm if orm set" do
        subject.instance_variable_set "@orm", mock_orm
        subject.orm.should eq mock_orm
      end

      context "orm isn't set" do
        before(:each) { subject.instance_variable_set "@orm", nil }

        it "should run autodetect if orm isn't set" do
          subject.should_receive(:autodetect)
          subject.orm
        end

        it "should return the result of autodetect if orm isn't set" do
          subject.stub(:autodetect).and_return(mock_orm)
          subject.orm.should eq mock_orm
        end
      end
    end

    describe "proxy methods" do
      let (:strategy) { double("strategy") }

      before(:each) do
        subject.stub(:strategy).and_return(strategy)
      end

      describe "start" do
        it "should proxy start to the strategy" do
          strategy.should_receive(:start)
          subject.start
        end
      end

      describe "clean" do
        it "should proxy clean to the strategy" do
          strategy.should_receive(:clean)
          subject.clean
        end
      end

      describe "clean!" do
        it "should proxy clean! to the strategy clean" do
          strategy.should_receive(:clean)
          subject.clean!
        end
      end

      describe "cleaning" do
        it "should proxy cleaning to the strategy" do
          strategy.should_receive(:cleaning)
          subject.cleaning { }
        end
      end
    end

    describe "auto_detected?" do
      it "should return true unless @autodetected is nil" do
        subject.instance_variable_set("@autodetected","not nil")
        subject.auto_detected?.should be_true
      end

      it "should return false if @autodetect is nil" do
        subject.instance_variable_set("@autodetected",nil)
        subject.auto_detected?.should be_false
      end
    end

    describe "orm_strategy" do
      let (:strategy_class) { double("strategy_class") }

      before(:each) do
        subject.stub(:orm_module).and_return(strategy_class)
      end

      context "in response to a LoadError" do
        before(:each) { subject.should_receive(:require).with(anything).and_raise(LoadError) }

        it "should raise UnknownStrategySpecified" do
          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should ask orm_module if it will list available_strategies" do
          strategy_class.should_receive(:respond_to?).with(:available_strategies)

          subject.stub(:orm_module).and_return(strategy_class)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should use available_strategies (for the error message) if its available" do
          strategy_class.stub(:respond_to?).with(:available_strategies).and_return(true)
          strategy_class.should_receive(:available_strategies).and_return([])

          subject.stub(:orm_module).and_return(strategy_class)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end
      end

      it "should return the constant of the Strategy class requested" do
        strategy_strategy_class = double("strategy strategy_class")

        subject.stub(:require).with(anything).and_return(true)

        strategy_class.should_receive(:const_get).with("Cunningplan").and_return(strategy_strategy_class)

        subject.send(:orm_strategy, :cunningplan).should eq strategy_strategy_class
      end

    end

    describe 'set_default_orm_strategy' do
      it 'sets strategy to :transaction for ActiveRecord' do
        cleaner = DatabaseCleaner::Base.new(:active_record)
        cleaner.strategy.should be_instance_of DatabaseCleaner::ActiveRecord::Transaction
      end

      it 'sets strategy to :transaction for DataMapper' do
        cleaner = DatabaseCleaner::Base.new(:data_mapper)
        cleaner.strategy.should be_instance_of DatabaseCleaner::DataMapper::Transaction
      end

      it 'sets strategy to :truncation for MongoMapper' do
        cleaner = DatabaseCleaner::Base.new(:mongo_mapper)
        cleaner.strategy.should be_instance_of DatabaseCleaner::MongoMapper::Truncation
      end

      it 'sets strategy to :truncation for Mongoid' do
        cleaner = DatabaseCleaner::Base.new(:mongoid)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Mongoid::Truncation
      end

      it 'sets strategy to :truncation for CouchPotato' do
        cleaner = DatabaseCleaner::Base.new(:couch_potato)
        cleaner.strategy.should be_instance_of DatabaseCleaner::CouchPotato::Truncation
      end

      it 'sets strategy to :transaction for Sequel' do
        cleaner = DatabaseCleaner::Base.new(:sequel)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Sequel::Transaction
      end

      it 'sets strategy to :truncation for Moped' do
        cleaner = DatabaseCleaner::Base.new(:moped)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Moped::Truncation
      end

      it 'sets strategy to :truncation for Ohm' do
        cleaner = DatabaseCleaner::Base.new(:ohm)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Ohm::Truncation
      end

      it 'sets strategy to :truncation for Redis' do
        cleaner = DatabaseCleaner::Base.new(:redis)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Redis::Truncation
      end

      it 'sets strategy to :transaction for Neo4j' do
        cleaner = DatabaseCleaner::Base.new(:neo4j)
        cleaner.strategy.should be_instance_of DatabaseCleaner::Neo4j::Transaction
      end
    end

  end
end
