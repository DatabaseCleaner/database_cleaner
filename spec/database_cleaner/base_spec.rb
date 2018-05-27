require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'
require 'database_cleaner/mongo_mapper/truncation'
require 'database_cleaner/mongoid/truncation'
require 'database_cleaner/couch_potato/truncation'
require 'database_cleaner/neo4j/transaction'

module DatabaseCleaner
  RSpec.describe Base do
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

      it "should raise an error when no ORM is detected" do
        expect { subject }.to raise_error(DatabaseCleaner::NoORMDetected, <<-ERROR.chomp)
No known ORM was detected!  Is ActiveRecord, DataMapper, MongoMapper, Mongoid, CouchPotato, Sequel, Moped, Ohm, Redis, or Neo4j loaded?
        ERROR
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

        expect(subject.orm).to eq :active_record
        expect(subject).to be_auto_detected
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

        expect(subject.orm).to eq :data_mapper
        expect(subject).to be_auto_detected
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

        expect(subject.orm).to eq :mongo_mapper
        expect(subject).to be_auto_detected
      end

      it "should detect Mongoid fourth" do
        stub_const('Mongoid',     'Mongoid mock')
        stub_const('CouchPotato', 'Couching mock potatos')
        stub_const('Sequel',      'Sequel mock')
        stub_const('Moped',       'Moped mock')
        stub_const('Ohm',         'Ohm mock')
        stub_const('Redis',       'Redis mock')
        stub_const('Neo4j',       'Neo4j mock')

        expect(subject.orm).to eq :mongoid
        expect(subject).to be_auto_detected
      end

      it "should detect CouchPotato fifth" do
        stub_const('CouchPotato', 'Couching mock potatos')
        stub_const('Sequel',      'Sequel mock')
        stub_const('Moped',       'Moped mock')
        stub_const('Ohm',         'Ohm mock')
        stub_const('Redis',       'Redis mock')
        stub_const('Neo4j',       'Neo4j mock')

        expect(subject.orm).to eq :couch_potato
        expect(subject).to be_auto_detected
      end

      it "should detect Sequel sixth" do
        stub_const('Sequel', 'Sequel mock')
        stub_const('Moped',  'Moped mock')
        stub_const('Ohm',    'Ohm mock')
        stub_const('Redis',  'Redis mock')
        stub_const('Neo4j',  'Neo4j mock')

        expect(subject.orm).to eq :sequel
        expect(subject).to be_auto_detected
      end

      it 'detects Moped seventh' do
        stub_const('Moped', 'Moped mock')

        expect(subject.orm).to eq :moped
        expect(subject).to be_auto_detected
      end

      it 'detects Ohm eighth' do
        stub_const('Ohm',    'Ohm mock')
        stub_const('Redis',  'Redis mock')
        stub_const('Neo4j',  'Neo4j mock')

        expect(subject.orm).to eq :ohm
        expect(subject).to be_auto_detected
      end

      it 'detects Redis ninth' do
        stub_const('Redis', 'Redis mock')
        stub_const('Neo4j', 'Neo4j mock')

        expect(subject.orm).to eq :redis
        expect(subject).to be_auto_detected
      end

      it 'detects Neo4j tenth' do
        stub_const('Neo4j', 'Neo4j mock')

        expect(subject.orm).to eq :neo4j
        expect(subject).to be_auto_detected
      end
    end

    describe "comparison" do
      it "should be equal if orm and connection are the same" do
        one = DatabaseCleaner::Base.new(:active_record, :connection => :default)
        two = DatabaseCleaner::Base.new(:active_record, :connection => :default)

        expect(one).to eq two
        expect(two).to eq one
      end

      it "should not be equal if orm are not the same" do
        one = DatabaseCleaner::Base.new(:mongo_id, :connection => :default)
        two = DatabaseCleaner::Base.new(:active_record, :connection => :default)

        expect(one).not_to eq two
        expect(two).not_to eq one
      end

      it "should not be equal if connection are not the same" do
        one = DatabaseCleaner::Base.new(:active_record, :connection => :default)
        two = DatabaseCleaner::Base.new(:active_record, :connection => :other)

        expect(one).not_to eq two
        expect(two).not_to eq one
      end
    end

    describe "initialization" do
      context "db specified" do
        subject { ::DatabaseCleaner::Base.new(:active_record, :connection => :my_db) }

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
        subject.db = :test_db
        expect(subject.db).to eq :test_db
      end
    end

    describe "db=" do
      context "when strategy supports db specification" do
        it "should pass db down to its current strategy" do
          expect(subject.strategy).to receive(:db=).with(:a_new_db)
          subject.db = :a_new_db
        end
      end

      context "when strategy doesn't support db specification" do
        let(:strategy) { double(respond_to?: false) }
        before { subject.strategy = strategy }

        it "doesn't pass the default db down to it" do
          expect(strategy).to_not receive(:db=)
          subject.db = :default
        end

        it "should raise an argument error when db isn't default" do
          expect { subject.db = :test }.to raise_error ArgumentError
        end
      end
    end

    describe "clean_with" do
      let (:strategy) { double("strategy", clean: true) }

      before do
        allow(subject).to receive(:create_strategy).with(anything).and_return(strategy)
      end
    end

    describe "clean_with" do
      # FIXME hacky null strategy
      # because you can't pass a NullStrategy to #clean_with

      let(:strategy) { double(clean: true) }

      let(:strategy_class) do
        require "database_cleaner/active_record/truncation"
        DatabaseCleaner::ActiveRecord::Truncation
      end

      before do
        allow(::ActiveRecord::Base).to receive(:connection).and_return(double.as_null_object)
        allow(strategy_class).to receive(:new).and_return(strategy)
      end

      it "should pass all arguments to strategy initializer" do
        expect(strategy_class).to receive(:new).with(:dollar, :amet, ipsum: "random").and_return(strategy)
        subject.clean_with :truncation, :dollar, :amet, ipsum: "random"
      end

      it "should invoke clean on the created strategy" do
        expect(strategy).to receive(:clean)
        subject.clean_with :truncation
      end

      it "should return the created strategy" do
        expect(subject.clean_with(:truncation)).to eq strategy
      end
    end

    describe "strategy=" do
      let(:strategy_class) do
        require "database_cleaner/active_record/truncation"
        DatabaseCleaner::ActiveRecord::Truncation
      end

      it "should look up and create a the named strategy for the current ORM" do
        subject.strategy = :truncation
        expect(subject.strategy).to be_a(strategy_class)
      end

      it "should proxy params with symbolised strategies" do
        expect(strategy_class).to receive(:new).with(param: "one")
        subject.strategy = :truncation, { param: "one" }
      end

      it "should accept strategy objects" do
        strategy = double
        subject.strategy = strategy
        expect(subject.strategy).to eq strategy
      end

      it "should raise argument error when params given with strategy object" do
        expect do
          subject.strategy = double, { param: "one" }
        end.to raise_error ArgumentError
      end

      it "should attempt to set strategy db" do
        strategy = double
        expect(strategy).to receive(:db=).with(:default)
        subject.strategy = strategy
      end

      it "raises UnknownStrategySpecified on a bad strategy, and lists available strategies" do
        expect { subject.strategy = :horrible_plan }.to \
          raise_error(UnknownStrategySpecified, "The 'horrible_plan' strategy does not exist for the active_record ORM!  Available strategies: truncation, transaction, deletion")
      end

      it "loads and instantiates the described strategy" do
        stub_const "DatabaseCleaner::ActiveRecord::Cunningplan", strategy_class

        subject.strategy = :cunningplan
        expect(subject.strategy).to be_a strategy_class
      end
    end

    describe "strategy" do
      subject { described_class.new(:a_orm) }

      it "returns a null strategy when strategy is not set and undetectable" do
        expect(subject.strategy).to be_a(DatabaseCleaner::NullStrategy)
      end
    end

    describe "orm" do
      let(:mock_orm) { double("orm") }

      it "should return orm if orm set" do
        subject.orm = :desired_orm
        expect(subject.orm).to eq :desired_orm
      end

      context "orm isn't set" do
        subject { described_class.new }

        it "should run autodetect if orm isn't set" do
          expect(subject).to be_auto_detected
        end

        it "should return the result of autodetect if orm isn't set" do
          expect(subject.orm).to eq :active_record
        end
      end
    end

    describe "proxy methods" do
      let (:strategy) { double("strategy") }

      before(:each) do
        subject.strategy = strategy
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

      describe "cleaning" do
        it "should proxy cleaning to the strategy" do
          expect(strategy).to receive(:cleaning)
          subject.cleaning { }
        end
      end
    end

    describe "autodetected?" do
      it "is true if auto detection was used" do
        expect(subject).to be_auto_detected
      end

      it "is false if orm was specified" do
        subject = described_class.new(:a_orm)
        expect(subject).to_not be_auto_detected
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
