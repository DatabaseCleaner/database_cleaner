require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'
require 'database_cleaner/mongo_mapper/truncation'
require 'database_cleaner/mongoid/truncation'
require 'database_cleaner/couch_potato/truncation'
require 'database_cleaner/neo4j/transaction'

module DatabaseCleaner
  describe Base do

    let(:mock_strategy) {
      double("strategy").tap{|strategy|
        allow(strategy).to receive_messages(:to_ary => [strategy])
      }
    }

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
         expect(running { cleaner }).to raise_error(DatabaseCleaner::NoORMDetected)
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

         expect(cleaner.orm).to eq :active_record
         expect(cleaner).to be_auto_detected
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

         expect(cleaner.orm).to eq :data_mapper
         expect(cleaner).to be_auto_detected
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

         expect(cleaner.orm).to eq :mongo_mapper
         expect(cleaner).to be_auto_detected
       end

       it "should detect Mongoid fourth" do
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :mongoid
         expect(cleaner).to be_auto_detected
       end

       it "should detect CouchPotato fifth" do
         Object.const_set('CouchPotato', 'Couching mock potatos')
         Object.const_set('Sequel',      'Sequel mock')
         Object.const_set('Moped',       'Moped mock')
         Object.const_set('Ohm',         'Ohm mock')
         Object.const_set('Redis',       'Redis mock')
         Object.const_set('Neo4j',       'Neo4j mock')

         expect(cleaner.orm).to eq :couch_potato
         expect(cleaner).to be_auto_detected
       end

       it "should detect Sequel sixth" do
         Object.const_set('Sequel', 'Sequel mock')
         Object.const_set('Moped',  'Moped mock')
         Object.const_set('Ohm',    'Ohm mock')
         Object.const_set('Redis',  'Redis mock')
         Object.const_set('Neo4j',  'Neo4j mock')

         expect(cleaner.orm).to eq :sequel
         expect(cleaner).to be_auto_detected
       end

       it 'detects Moped seventh' do
         Object.const_set('Moped', 'Moped mock')

         expect(cleaner.orm).to eq :moped
         expect(cleaner).to be_auto_detected
       end

       it 'detects Ohm eighth' do
         Object.const_set('Ohm',    'Ohm mock')
         Object.const_set('Redis',  'Redis mock')
         Object.const_set('Neo4j',  'Neo4j mock')

         expect(cleaner.orm).to eq :ohm
         expect(cleaner).to be_auto_detected
       end

       it 'detects Redis ninth' do
         Object.const_set('Redis', 'Redis mock')
         Object.const_set('Neo4j', 'Neo4j mock')

         expect(cleaner.orm).to eq :redis
         expect(cleaner).to be_auto_detected
       end

       it 'detects Neo4j tenth' do
         Object.const_set('Neo4j', 'Neo4j mock')

         expect(cleaner.orm).to eq :neo4j
         expect(cleaner).to be_auto_detected
       end
    end

    describe "orm_module" do
      it "should ask ::DatabaseCleaner what the module is for its orm" do
        orm = double("orm")
        mockule = double("module")

        cleaner = ::DatabaseCleaner::Base.new
        expect(cleaner).to receive(:orm).and_return(orm)

        expect(::DatabaseCleaner).to receive(:orm_module).with(orm).and_return(mockule)

        expect(cleaner.send(:orm_module)).to eq mockule
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
