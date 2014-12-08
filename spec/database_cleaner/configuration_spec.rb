require 'spec_helper'
module ArrayHelper
  def zipmap(array, vals)
    Hash[*(array.zip(vals).flatten)]
  end
  module_function :zipmap
end

module DatabaseCleaner
  class << self
    def reset
      @cleaners = nil
      @connections = nil
    end
    # hackey, hack.. connections needs to stick around until I can properly deprecate the API
    def connections_stub(array)
      @cleaners = ArrayHelper.zipmap((1..array.size).to_a, array)
      @connections = array
    end
  end
end

describe ::DatabaseCleaner do
  before(:each) { ::DatabaseCleaner.reset }

  context "orm specification" do
    it "should not accept unrecognised orms" do
      expect { ::DatabaseCleaner[nil] }.to raise_error(::DatabaseCleaner::NoORMDetected)
    end

    it "should accept :active_record" do
      cleaner = ::DatabaseCleaner[:active_record]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :active_record
      ::DatabaseCleaner.connections.size.should eq 1
    end

    it "should accept :data_mapper" do
      cleaner = ::DatabaseCleaner[:data_mapper]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :data_mapper
      ::DatabaseCleaner.connections.size.should eq 1
    end

    it "should accept :mongo_mapper" do
      cleaner = ::DatabaseCleaner[:mongo_mapper]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :mongo_mapper
      ::DatabaseCleaner.connections.size.should eq 1
    end

    it "should accept :couch_potato" do
      cleaner = ::DatabaseCleaner[:couch_potato]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :couch_potato
      ::DatabaseCleaner.connections.size.should eq 1
    end

    it "should accept :moped" do
      cleaner = ::DatabaseCleaner[:moped]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :moped
      ::DatabaseCleaner.connections.size.should eq 1
    end

    it 'accepts :ohm' do
      cleaner = ::DatabaseCleaner[:ohm]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :ohm
      ::DatabaseCleaner.connections.size.should eq 1
    end
  end

  it "should accept multiple orm's" do
    ::DatabaseCleaner[:couch_potato]
    ::DatabaseCleaner[:data_mapper]
    ::DatabaseCleaner.connections.size.should eq 2
    ::DatabaseCleaner.connections[0].orm.should eq :couch_potato
    ::DatabaseCleaner.connections[1].orm.should eq :data_mapper
  end

  context "connection/db specification" do
    it "should accept a connection parameter and store it" do
      cleaner = ::DatabaseCleaner[:active_record, {:connection => :first_connection}]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should eq :active_record
      cleaner.db.should eq :first_connection
    end

    it "should accept multiple connections for a single orm" do
      ::DatabaseCleaner[:data_mapper,{:connection => :first_db}]
      ::DatabaseCleaner[:data_mapper,{:connection => :second_db}]
      ::DatabaseCleaner.connections.size.should eq 2
      ::DatabaseCleaner.connections[0].orm.should eq :data_mapper
      ::DatabaseCleaner.connections[0].db.should  eq :first_db
      ::DatabaseCleaner.connections[1].orm.should eq :data_mapper
      ::DatabaseCleaner.connections[1].db.should  eq :second_db
    end

    it "should accept multiple connections and multiple orms" do
      ::DatabaseCleaner[:data_mapper,  {:connection => :first_db} ]
      ::DatabaseCleaner[:active_record,{:connection => :second_db}]
      ::DatabaseCleaner[:active_record,{:connection => :first_db} ]
      ::DatabaseCleaner[:data_mapper,  {:connection => :second_db}]

      ::DatabaseCleaner.connections.size.should eq 4

      ::DatabaseCleaner.connections[0].orm.should eq :data_mapper
      ::DatabaseCleaner.connections[0].db.should  eq :first_db

      ::DatabaseCleaner.connections[1].orm.should eq :active_record
      ::DatabaseCleaner.connections[1].db.should  eq :second_db

      ::DatabaseCleaner.connections[2].orm.should eq :active_record
      ::DatabaseCleaner.connections[2].db.should  eq :first_db

      ::DatabaseCleaner.connections[3].orm.should eq :data_mapper
      ::DatabaseCleaner.connections[3].db.should  eq :second_db
    end
  end

  context "connection/db retrieval" do
    it "should retrieve a db rather than create a new one" do
      pending
      connection = ::DatabaseCleaner[:active_record].strategy = :truncation
      ::DatabaseCleaner[:active_record].should eq connection
    end
  end

  context "class methods" do
    subject { ::DatabaseCleaner }

    it "should give me a default (autodetection) databasecleaner by default" do
      cleaner = double("cleaner").as_null_object
      ::DatabaseCleaner::Base.stub(:new).and_return(cleaner)

      ::DatabaseCleaner.connections.should eq [cleaner]
    end
  end

  context "single orm single connection" do
    let(:connection) { ::DatabaseCleaner.connections.first }

    it "should proxy strategy=" do
      stratagum = double("stratagum")
      connection.should_receive(:strategy=).with(stratagum)
      ::DatabaseCleaner.strategy = stratagum
    end

    it "should proxy orm=" do
      orm = double("orm")
      connection.should_receive(:orm=).with(orm)
      ::DatabaseCleaner.orm = orm
    end

    it "should proxy start" do
      connection.should_receive(:start)
      ::DatabaseCleaner.start
    end

    it "should proxy clean" do
      connection.should_receive(:clean)
      ::DatabaseCleaner.clean
    end

    it 'should proxy cleaning' do
      connection.should_receive(:cleaning)
      ::DatabaseCleaner.cleaning { }
    end

    it "should proxy clean_with" do
      stratagem = double("stratgem")
      connection.should_receive(:clean_with).with(stratagem, {})
      ::DatabaseCleaner.clean_with stratagem, {}
    end
  end

  context "multiple connections" do

    #these are relativly simple, all we need to do is make sure all connections are cleaned/started/cleaned_with appropriatly.
    context "simple proxy methods" do

      let(:active_record) { double("active_mock") }
      let(:data_mapper)   { double("data_mock")   }

      before(:each) do
        ::DatabaseCleaner.stub(:connections).and_return([active_record,data_mapper])
      end

      it "should proxy orm to all connections" do
        active_record.should_receive(:orm=)
        data_mapper.should_receive(:orm=)

        ::DatabaseCleaner.orm = double("orm")
      end

      it "should proxy start to all connections" do
        active_record.should_receive(:start)
        data_mapper.should_receive(:start)

        ::DatabaseCleaner.start
      end

      it "should proxy clean to all connections" do
        active_record.should_receive(:clean)
        data_mapper.should_receive(:clean)

        ::DatabaseCleaner.clean
      end

      it "should initiate cleaning on each connection, yield, and finish cleaning each connection" do
        [active_record, data_mapper].each do |connection|
          mc = class << connection; self; end
          mc.send(:attr_reader, :started, :cleaned)
          mc.send(:define_method, 'cleaning') do |&block|
            @started = true
            block.call
            @cleaned = true
          end
        end

        ::DatabaseCleaner.cleaning do
          active_record.started.should == true
          data_mapper.started.should == true
          active_record.cleaned.should == nil
          data_mapper.cleaned.should == nil
          @yielded = true
        end
        active_record.cleaned.should == true
        data_mapper.cleaned.should == true
      end

      it "should proxy clean_with to all connections" do
        stratagem = double("stratgem")
        active_record.should_receive(:clean_with).with(stratagem)
        data_mapper.should_receive(:clean_with).with(stratagem)

        ::DatabaseCleaner.clean_with stratagem
      end
    end

    # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could
    # plausably want to force orm/strategy change on two sets of orm that differ only on db
    context "multiple orm proxy methods" do

      pending "should proxy orm to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_on_db_one").as_null_object
        active_record_2 = double("active_mock_on_db_two").as_null_object
        data_mapper_1   = double("data_mock_on_db_one").as_null_object

        ::DatabaseCleaner.connections_stub [active_record_1,active_record_2,data_mapper_1]

        active_record_1.should_receive(:orm=).with(:data_mapper)
        active_record_2.should_receive(:orm=).with(:data_mapper)
        data_mapper_1.should_receive(:orm=).with(:data_mapper)

        active_record_1.should_receive(:==).with(data_mapper_1).and_return(true)

        ::DatabaseCleaner.connections.size.should eq 3
        ::DatabaseCleaner.orm = :data_mapper
        ::DatabaseCleaner.connections.size.should eq 2
      end

      it "should proxy strategy to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_strategy_one").as_null_object
        active_record_2 = double("active_mock_strategy_two").as_null_object
        strategy = double("strategy")

        ::DatabaseCleaner.connections_stub [active_record_1,active_record_2]

        active_record_1.should_receive(:strategy=).with(strategy)
        active_record_2.should_receive(:strategy=).with(strategy)

        active_record_1.should_receive(:==).with(active_record_2).and_return(true)

        ::DatabaseCleaner.connections.size.should eq 2
        ::DatabaseCleaner.strategy = strategy
        ::DatabaseCleaner.connections.size.should eq 1
      end
    end
  end

  describe "remove_duplicates" do
    it "should remove duplicates if they are identical" do
      orm = double("orm")
      connection = double("a datamapper connection", :orm => orm )

      ::DatabaseCleaner.connections_stub  [connection,connection,connection]

      ::DatabaseCleaner.remove_duplicates
      ::DatabaseCleaner.connections.size.should eq 1
    end
  end

  describe "app_root" do
    it "should default to Dir.pwd" do
      DatabaseCleaner.app_root.should eq Dir.pwd
    end

    it "should store specific paths" do
      DatabaseCleaner.app_root = '/path/to'
      DatabaseCleaner.app_root.should eq '/path/to'
    end
  end

  describe "orm_module" do
    subject { ::DatabaseCleaner }

    it "should return DatabaseCleaner::ActiveRecord for :active_record" do
      ::DatabaseCleaner::ActiveRecord = double("ar module") unless defined? ::DatabaseCleaner::ActiveRecord
      subject.orm_module(:active_record).should eq DatabaseCleaner::ActiveRecord
    end

    it "should return DatabaseCleaner::DataMapper for :data_mapper" do
      ::DatabaseCleaner::DataMapper = double("dm module") unless defined? ::DatabaseCleaner::DataMapper
      subject.orm_module(:data_mapper).should eq DatabaseCleaner::DataMapper
    end

    it "should return DatabaseCleaner::MongoMapper for :mongo_mapper" do
      ::DatabaseCleaner::MongoMapper = double("mm module") unless defined? ::DatabaseCleaner::MongoMapper
      subject.orm_module(:mongo_mapper).should eq DatabaseCleaner::MongoMapper
    end

    it "should return DatabaseCleaner::Mongoid for :mongoid" do
      ::DatabaseCleaner::Mongoid = double("mongoid module") unless defined? ::DatabaseCleaner::Mongoid
      subject.orm_module(:mongoid).should eq DatabaseCleaner::Mongoid
    end

    it "should return DatabaseCleaner::Mongo for :mongo" do
      ::DatabaseCleaner::Mongo = double("mongo module") unless defined? ::DatabaseCleaner::Mongo
      subject.orm_module(:mongo).should eq DatabaseCleaner::Mongo
    end

    it "should return DatabaseCleaner::CouchPotato for :couch_potato" do
      ::DatabaseCleaner::CouchPotato = double("cp module") unless defined? ::DatabaseCleaner::CouchPotato
      subject.orm_module(:couch_potato).should eq DatabaseCleaner::CouchPotato
    end

    it "should return DatabaseCleaner::Neo4j for :neo4j" do
      ::DatabaseCleaner::Neo4j = double("nj module") unless defined? ::DatabaseCleaner::Neo4j
      subject.orm_module(:neo4j).should eq DatabaseCleaner::Neo4j
    end

  end
end
