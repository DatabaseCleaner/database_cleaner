require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'
require 'database_cleaner/mongo_mapper/truncation'
require 'database_cleaner/mongoid/truncation'
require 'database_cleaner/couch_potato/truncation'
require 'database_cleaner/neo4j/transaction'

module DatabaseCleaner
  RSpec.describe Base do

    let(:mock_strategy) {
      double("strategy").tap{|strategy|
        allow(strategy).to receive_messages(:to_ary => [strategy])
      }
    }

    describe "autodetect" do
       before do
         hide_const("ActiveRecord")
         hide_const("DataMapper")
         hide_const("MongoMapper")
         hide_const("Mongoid")
         hide_const("CouchPotato")
         hide_const("Sequel")
         hide_const("Moped")
         hide_const("Redis")
         hide_const("Ohm")
         hide_const("Neo4j")
       end

       let(:cleaner) { DatabaseCleaner::Base.new :autodetect }

       it "should raise an error when no ORM is detected" do
         expect { cleaner }.to raise_error(DatabaseCleaner::NoORMDetected)
       end

       it "should detect ActiveRecord first" do
         stub_const('ActiveRecord','Actively mocking records.')
         stub_const('DataMapper',  'Mapping data mocks')
         stub_const('MongoMapper', 'Mapping mock mongos')
         stub_const('Mongoid',     'Mongoid mock')
         stub_const('CouchPotato', 'Couching mock potatos')
         stub_const('Sequel',      'Sequel mock')
         stub_const('Moped',       'Moped mock')
         stub_const('Ohm',         'Ohm mock')
         stub_const('Redis',       'Redis mock')
         stub_const('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :active_record
         expect(cleaner).to be_auto_detected
       end

       it "should detect DataMapper second" do
         stub_const('DataMapper',  'Mapping data mocks')
         stub_const('MongoMapper', 'Mapping mock mongos')
         stub_const('Mongoid',     'Mongoid mock')
         stub_const('CouchPotato', 'Couching mock potatos')
         stub_const('Sequel',      'Sequel mock')
         stub_const('Moped',       'Moped mock')
         stub_const('Ohm',         'Ohm mock')
         stub_const('Redis',       'Redis mock')
         stub_const('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :data_mapper
         expect(cleaner).to be_auto_detected
       end

       it "should detect MongoMapper third" do
         stub_const('MongoMapper', 'Mapping mock mongos')
         stub_const('Mongoid',     'Mongoid mock')
         stub_const('CouchPotato', 'Couching mock potatos')
         stub_const('Sequel',      'Sequel mock')
         stub_const('Moped',       'Moped mock')
         stub_const('Ohm',         'Ohm mock')
         stub_const('Redis',       'Redis mock')
         stub_const('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :mongo_mapper
         expect(cleaner).to be_auto_detected
       end

       it "should detect Mongoid fourth" do
         stub_const('Mongoid',     'Mongoid mock')
         stub_const('CouchPotato', 'Couching mock potatos')
         stub_const('Sequel',      'Sequel mock')
         stub_const('Moped',       'Moped mock')
         stub_const('Ohm',         'Ohm mock')
         stub_const('Redis',       'Redis mock')
         stub_const('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :mongoid
         expect(cleaner).to be_auto_detected
       end

       it "should detect CouchPotato fifth" do
         stub_const('CouchPotato', 'Couching mock potatos')
         stub_const('Sequel',      'Sequel mock')
         stub_const('Moped',       'Moped mock')
         stub_const('Ohm',         'Ohm mock')
         stub_const('Redis',       'Redis mock')
         stub_const('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :couch_potato
         expect(cleaner).to be_auto_detected
       end

       it "should detect Sequel sixth" do
         stub_const('Sequel', 'Sequel mock')
         stub_const('Moped',  'Moped mock')
         stub_const('Ohm',    'Ohm mock')
         stub_const('Redis',  'Redis mock')
         stub_const('Neo4j',  'Neo4j mock')

         expect(cleaner.orm).to eq :sequel
         expect(cleaner).to be_auto_detected
       end

       it 'detects Moped seventh' do
         stub_const('Moped', 'Moped mock')

         expect(cleaner.orm).to eq :moped
         expect(cleaner).to be_auto_detected
       end

       it 'detects Ohm eighth' do
         stub_const('Ohm',    'Ohm mock')
         stub_const('Redis',  'Redis mock')
         stub_const('Neo4j',  'Neo4j mock')

         expect(cleaner.orm).to eq :ohm
         expect(cleaner).to be_auto_detected
       end

       it 'detects Redis ninth' do
         stub_const('Redis', 'Redis mock')
         stub_const('Neo4j', 'Neo4j mock')

         expect(cleaner.orm).to eq :redis
         expect(cleaner).to be_auto_detected
       end

       it 'detects Neo4j tenth' do
         stub_const('Neo4j', 'Neo4j mock')

         expect(cleaner.orm).to eq :neo4j
         expect(cleaner).to be_auto_detected
       end
    end

    describe "orm_module" do
      let(:mod) { double(const_get: Class.new) } # stub strategy lookup

      it "should return DatabaseCleaner::ActiveRecord for :active_record" do
        stub_const "DatabaseCleaner::ActiveRecord", mod
        subject.orm = :active_record
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::DataMapper for :data_mapper" do
        stub_const "DatabaseCleaner::DataMapper", mod
        subject.orm = :data_mapper
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::MongoMapper for :mongo_mapper" do
        stub_const "DatabaseCleaner::MongoMapper", mod
        subject.orm = :mongo_mapper
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::Mongoid for :mongoid" do
        stub_const "DatabaseCleaner::Mongoid", mod
        subject.orm = :mongoid
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::Mongo for :mongo" do
        stub_const "DatabaseCleaner::Mongo", mod
        subject.orm = :mongo
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::CouchPotato for :couch_potato" do
        stub_const "DatabaseCleaner::CouchPotato", mod
        subject.orm = :couch_potato
        expect(subject.send(:orm_module)).to eq mod
      end

      it "should return DatabaseCleaner::Neo4j for :neo4j" do
        stub_const "DatabaseCleaner::Neo4j", mod
        subject.orm = :neo4j
        expect(subject.send(:orm_module)).to eq mod
      end
    end

    describe "comparison" do
      it "should be equal if orm, connection and strategy are the same" do
        one = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        one.strategy = mock_strategy

        two = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        two.strategy = mock_strategy

        expect(one).to eq two
        expect(two).to eq one
      end

      it "should not be equal if orm are not the same" do
        one = DatabaseCleaner::Base.new(:mongo_id, :connection => :default)
        one.strategy = mock_strategy

        two = DatabaseCleaner::Base.new(:active_record, :connection => :default)
        two.strategy = mock_strategy

        expect(one).not_to eq two
        expect(two).not_to eq one
      end

      it "should not be equal if connection are not the same" do

        one = DatabaseCleaner::Base.new(:active_record, :connection => :default)
        one.strategy = :truncation

        two = DatabaseCleaner::Base.new(:active_record, :connection => :other)
        two.strategy = :truncation

        expect(one).not_to eq two
        expect(two).not_to eq one
      end
    end

    describe "initialization" do
      context "db specified" do
        subject { ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db) }

        it "should store db from :connection in params hash" do
          expect(subject.db).to eq :my_db
        end
      end

      describe "orm" do
        it "should store orm" do
          cleaner = ::DatabaseCleaner::Base.new :a_orm
          expect(cleaner.orm).to eq :a_orm
        end

        it "converts string to symbols" do
          cleaner = ::DatabaseCleaner::Base.new "mongoid"
          expect(cleaner.orm).to eq :mongoid
        end

        it "is autodetected if orm is not provided" do
          cleaner = ::DatabaseCleaner::Base.new
          expect(cleaner).to be_auto_detected
        end

        it "is autodetected if you specify :autodetect" do
          cleaner = ::DatabaseCleaner::Base.new "autodetect"
          expect(cleaner).to be_auto_detected
        end

        it "should default to autodetect upon initalisation" do
          expect(subject).to be_auto_detected
        end
      end
    end

    describe "db" do
      it "should default to :default" do
        expect(subject.db).to eq :default
      end

      it "should return any stored db value" do
        allow(subject).to receive(:strategy_db=)
        subject.db = :test_db
        expect(subject.db).to eq :test_db
      end

      it "should pass db to any specified strategy" do
        expect(subject).to receive(:strategy_db=).with(:a_new_db)
        subject.db = :a_new_db
      end
    end

    describe "strategy_db=" do
      let(:strategy) { mock_strategy }

      before(:each) do
        subject.strategy = strategy
      end

      it "should check that strategy supports db specification" do
        allow(strategy).to receive(:db=)
        subject.strategy_db = :a_db
      end

      context "when strategy supports db specification" do
        it "should pass db to the strategy" do
          expect(strategy).to receive(:db=).with(:a_db)
          subject.strategy_db = :a_db
        end
      end

      context "when strategy doesn't supports db specification" do
        it "should check to see if db is :default" do
          db = double("default")
          expect(db).to receive(:==).with(:default).and_return(true)

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

      before(:each) { allow(subject).to receive(:create_strategy).with(anything).and_return(strategy) }

      it "should pass all arguments to create_strategy" do
        expect(subject).to receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with :lorum, :dollar, :amet, { :ipsum => "random" }
      end

      it "should invoke clean on the created strategy" do
        expect(strategy).to receive(:clean)
        subject.clean_with :strategy
      end

      it "should return the strategy" do
        expect(subject.clean_with( :strategy )).to eq strategy
      end
    end

    describe "clean_with!" do
      let (:strategy) { double("strategy",:clean => true) }

      before(:each) { allow(subject).to receive(:create_strategy).with(anything).and_return(strategy) }

      it "should pass all arguments to create_strategy" do
        expect(subject).to receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with! :lorum, :dollar, :amet, { :ipsum => "random" }
      end

      it "should invoke clean on the created strategy" do
        expect(strategy).to receive(:clean)
        subject.clean_with! :strategy
      end

      it "should return the strategy" do
        expect(subject.clean_with!( :strategy )).to eq strategy
      end
    end

    describe "create_strategy" do
      let(:strategy_class) { double("strategy_class",:new => double("instance")) }

      before :each do
        allow(subject).to receive(:orm_strategy).and_return(strategy_class)
      end

      it "should pass the first argument to orm_strategy" do
        expect(subject).to receive(:orm_strategy).with(:strategy).and_return(Object)
        subject.create_strategy :strategy
      end
      it "should pass the remainding argument to orm_strategy.new" do
        expect(strategy_class).to receive(:new).with(:params => {:lorum => "ipsum"})

        subject.create_strategy :strategy, {:params => {:lorum => "ipsum"}}
      end
      it "should return the resulting strategy" do
        expect(subject.create_strategy( :strategy )).to eq strategy_class.new
      end
    end

    describe "strategy=" do
      it "should proxy symbolised strategies to create_strategy" do
        expect(subject).to receive(:create_strategy).with(:symbol)
        subject.strategy = :symbol
      end

      it "should proxy params with symbolised strategies" do
        expect(subject).to receive(:create_strategy).with(:symbol,:param => "one")
        subject.strategy= :symbol, {:param => "one"}
      end

      it "should accept strategy objects" do
        expect{ subject.strategy = mock_strategy }.to_not raise_error
      end

      it "should raise argument error when params given with strategy Object" do
        expect{ subject.strategy = double("object"), {:param => "one"} }.to raise_error ArgumentError
      end

      it "should attempt to set strategy db" do
        allow(subject).to receive(:db).and_return(:my_db)
        expect(subject).to receive(:set_strategy_db).with(mock_strategy, :my_db)
        subject.strategy = mock_strategy
      end

      it "should return the stored strategy" do
        result = subject.strategy = mock_strategy
        expect(result).to eq mock_strategy
      end
    end

    describe "strategy" do
      subject { ::DatabaseCleaner::Base.new :a_orm }

      it "returns a null strategy when strategy is not set and undetectable" do
        expect(subject.strategy).to eq DatabaseCleaner::NullStrategy
      end

      it "returns the set strategy" do
        subject.strategy = mock_strategy
        expect(subject.strategy).to eq mock_strategy
      end
    end

    describe "orm=" do
      it "should stored the desired orm" do
        expect(subject.orm).not_to eq :desired_orm
        subject.orm = :desired_orm
        expect(subject.orm).to eq :desired_orm
      end
    end

    describe "orm" do
      let(:mock_orm) { double("orm") }

      it "should return orm if orm set" do
        subject.instance_variable_set "@orm", mock_orm
        expect(subject.orm).to eq mock_orm
      end

      context "orm isn't set" do
        before(:each) { subject.instance_variable_set "@orm", nil }

        it "should run autodetect if orm isn't set" do
          expect(subject).to receive(:autodetect)
          subject.orm
        end

        it "should return the result of autodetect if orm isn't set" do
          allow(subject).to receive(:autodetect).and_return(mock_orm)
          expect(subject.orm).to eq mock_orm
        end
      end
    end

    describe "proxy methods" do
      let (:strategy) { double("strategy") }

      before(:each) do
        allow(subject).to receive(:strategy).and_return(strategy)
      end

      describe "start" do
        it "should proxy start to the strategy" do
          expect(strategy).to receive(:start)
          subject.start
        end
      end

      describe "clean" do
        it "should proxy clean to the strategy" do
          expect(strategy).to receive(:clean)
          subject.clean
        end
      end

      describe "clean!" do
        it "should proxy clean! to the strategy clean" do
          expect(strategy).to receive(:clean)
          subject.clean!
        end
      end

      describe "cleaning" do
        it "should proxy cleaning to the strategy" do
          expect(strategy).to receive(:cleaning)
          subject.cleaning { }
        end
      end
    end

    describe "auto_detected?" do
      it "should return true unless @autodetected is nil" do
        subject.instance_variable_set("@autodetected","not nil")
        expect(subject.auto_detected?).to be_truthy
      end

      it "should return false if @autodetect is nil" do
        subject.instance_variable_set("@autodetected",nil)
        expect(subject.auto_detected?).to be_falsey
      end
    end

    describe "orm_strategy" do
      let (:strategy_class) { double("strategy_class") }

      before(:each) do
        allow(subject).to receive(:orm_module).and_return(strategy_class)
      end

      context "in response to a LoadError" do
        before(:each) { expect(subject).to receive(:require).with(anything).and_raise(LoadError) }

        it "should raise UnknownStrategySpecified" do
          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should ask orm_module if it will list available_strategies" do
          expect(strategy_class).to receive(:respond_to?).with(:available_strategies)

          allow(subject).to receive(:orm_module).and_return(strategy_class)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should use available_strategies (for the error message) if its available" do
          expect(strategy_class).to receive(:available_strategies).and_return([])

          allow(subject).to receive(:orm_module).and_return(strategy_class)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end
      end

      it "should return the constant of the Strategy class requested" do
        strategy_strategy_class = double("strategy strategy_class")

        allow(subject).to receive(:require).with(anything).and_return(true)

        expect(strategy_class).to receive(:const_get).with("Cunningplan").and_return(strategy_strategy_class)

        expect(subject.send(:orm_strategy, :cunningplan)).to eq strategy_strategy_class
      end

    end

    describe 'set_default_orm_strategy' do
      it 'sets strategy to :transaction for ActiveRecord' do
        cleaner = DatabaseCleaner::Base.new(:active_record)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::ActiveRecord::Transaction
      end

      it 'sets strategy to :transaction for DataMapper' do
        cleaner = DatabaseCleaner::Base.new(:data_mapper)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::DataMapper::Transaction
      end

      it 'sets strategy to :truncation for MongoMapper' do
        cleaner = DatabaseCleaner::Base.new(:mongo_mapper)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::MongoMapper::Truncation
      end

      it 'sets strategy to :truncation for Mongoid' do
        cleaner = DatabaseCleaner::Base.new(:mongoid)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Mongoid::Truncation
      end

      it 'sets strategy to :truncation for CouchPotato' do
        cleaner = DatabaseCleaner::Base.new(:couch_potato)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::CouchPotato::Truncation
      end

      it 'sets strategy to :transaction for Sequel' do
        cleaner = DatabaseCleaner::Base.new(:sequel)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Sequel::Transaction
      end

      it 'sets strategy to :truncation for Moped' do
        cleaner = DatabaseCleaner::Base.new(:moped)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Moped::Truncation
      end

      it 'sets strategy to :truncation for Ohm' do
        cleaner = DatabaseCleaner::Base.new(:ohm)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Ohm::Truncation
      end

      it 'sets strategy to :truncation for Redis' do
        cleaner = DatabaseCleaner::Base.new(:redis)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Redis::Truncation
      end

      it 'sets strategy to :transaction for Neo4j' do
        cleaner = DatabaseCleaner::Base.new(:neo4j)
        expect(cleaner.strategy).to be_instance_of DatabaseCleaner::Neo4j::Transaction
      end
    end

  end
end
