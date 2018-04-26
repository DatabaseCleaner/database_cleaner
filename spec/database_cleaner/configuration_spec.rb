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
      @app_root = nil
    end
    # hackey, hack.. connections needs to stick around until I can properly deprecate the API
    def connections_stub(array)
      @cleaners = ArrayHelper.zipmap((1..array.size).to_a, array)
      @connections = array
    end
  end
end

describe DatabaseCleaner do
  before(:each) { DatabaseCleaner.reset }

  context "orm specification" do
    it "should not accept unrecognised orms" do
      expect { DatabaseCleaner[nil] }.to raise_error(DatabaseCleaner::NoORMDetected)
    end

    it "should accept :active_record" do
      cleaner = DatabaseCleaner[:active_record]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(DatabaseCleaner.connections.size).to eq 1
    end

    it "should accept :data_mapper" do
      cleaner = DatabaseCleaner[:data_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :data_mapper
      expect(DatabaseCleaner.connections.size).to eq 1
    end

    it "should accept :mongo_mapper" do
      cleaner = DatabaseCleaner[:mongo_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :mongo_mapper
      expect(DatabaseCleaner.connections.size).to eq 1
    end

    it "should accept :couch_potato" do
      cleaner = DatabaseCleaner[:couch_potato]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :couch_potato
      expect(DatabaseCleaner.connections.size).to eq 1
    end

    it "should accept :moped" do
      cleaner = DatabaseCleaner[:moped]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :moped
      expect(DatabaseCleaner.connections.size).to eq 1
    end

    it 'accepts :ohm' do
      cleaner = DatabaseCleaner[:ohm]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :ohm
      expect(DatabaseCleaner.connections.size).to eq 1
    end
  end

  it "should accept multiple orm's" do
    DatabaseCleaner[:couch_potato]
    DatabaseCleaner[:data_mapper]
    expect(DatabaseCleaner.connections.size).to eq 2
    expect(DatabaseCleaner.connections[0].orm).to eq :couch_potato
    expect(DatabaseCleaner.connections[1].orm).to eq :data_mapper
  end

  context "connection/db specification" do
    it "should accept a connection parameter and store it" do
      cleaner = DatabaseCleaner[:active_record, {:connection => :first_connection}]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(cleaner.db).to eq :first_connection
    end

    it "should accept multiple connections for a single orm" do
      DatabaseCleaner[:data_mapper,{:connection => :first_db}]
      DatabaseCleaner[:data_mapper,{:connection => :second_db}]
      expect(DatabaseCleaner.connections.size).to eq 2
      expect(DatabaseCleaner.connections[0].orm).to eq :data_mapper
      expect(DatabaseCleaner.connections[0].db).to  eq :first_db
      expect(DatabaseCleaner.connections[1].orm).to eq :data_mapper
      expect(DatabaseCleaner.connections[1].db).to  eq :second_db
    end

    it "should accept multiple connections and multiple orms" do
      DatabaseCleaner[:data_mapper,  {:connection => :first_db} ]
      DatabaseCleaner[:active_record,{:connection => :second_db}]
      DatabaseCleaner[:active_record,{:connection => :first_db} ]
      DatabaseCleaner[:data_mapper,  {:connection => :second_db}]

      expect(DatabaseCleaner.connections.size).to eq 4

      expect(DatabaseCleaner.connections[0].orm).to eq :data_mapper
      expect(DatabaseCleaner.connections[0].db).to  eq :first_db

      expect(DatabaseCleaner.connections[1].orm).to eq :active_record
      expect(DatabaseCleaner.connections[1].db).to  eq :second_db

      expect(DatabaseCleaner.connections[2].orm).to eq :active_record
      expect(DatabaseCleaner.connections[2].db).to  eq :first_db

      expect(DatabaseCleaner.connections[3].orm).to eq :data_mapper
      expect(DatabaseCleaner.connections[3].db).to  eq :second_db
    end
  end

  context "connection/db retrieval" do
    it "should retrieve a db rather than create a new one" do
      pending
      connection = DatabaseCleaner[:active_record].strategy = :truncation
      expect(DatabaseCleaner[:active_record]).to eq connection
    end
  end

  context "class methods" do
    subject { DatabaseCleaner }

    it "should give me a default (autodetection) databasecleaner by default" do
      cleaner = double("cleaner").as_null_object
      allow(DatabaseCleaner::Base).to receive(:new).and_return(cleaner)

      expect(DatabaseCleaner.connections).to eq [cleaner]
    end
  end

  context "single orm single connection" do
    let(:connection) { DatabaseCleaner.connections.first }

    it "should proxy strategy=" do
      stratagem = double("stratagem")
      expect(connection).to receive(:strategy=).with(stratagem)
      DatabaseCleaner.strategy = stratagem
    end

    it "should proxy orm=" do
      orm = double("orm")
      expect(connection).to receive(:orm=).with(orm)
      DatabaseCleaner.orm = orm
    end

    it "should proxy start" do
      expect(connection).to receive(:start)
      DatabaseCleaner.start
    end

    it "should proxy clean" do
      expect(connection).to receive(:clean)
      DatabaseCleaner.clean
    end

    it 'should proxy cleaning' do
      expect(connection).to receive(:cleaning)
      DatabaseCleaner.cleaning { }
    end

    it "should proxy clean_with" do
      stratagem = double("stratgem")
      expect(connection).to receive(:clean_with).with(stratagem, {})
      DatabaseCleaner.clean_with stratagem, {}
    end
  end

  context "multiple connections" do

    # these are relatively simple, all we need to do is make sure all connections are cleaned/started/cleaned_with appropriately.
    context "simple proxy methods" do

      let(:active_record) { double("active_mock") }
      let(:data_mapper)   { double("data_mock")   }

      before(:each) do
        allow(DatabaseCleaner).to receive(:connections).and_return([active_record,data_mapper])
      end

      it "should proxy orm to all connections" do
        expect(active_record).to receive(:orm=)
        expect(data_mapper).to receive(:orm=)

        DatabaseCleaner.orm = double("orm")
      end

      it "should proxy start to all connections" do
        expect(active_record).to receive(:start)
        expect(data_mapper).to receive(:start)

        DatabaseCleaner.start
      end

      it "should proxy clean to all connections" do
        expect(active_record).to receive(:clean)
        expect(data_mapper).to receive(:clean)

        DatabaseCleaner.clean
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

        DatabaseCleaner.cleaning do
          expect(active_record.started).to eq(true)
          expect(data_mapper.started).to eq(true)
          expect(active_record.cleaned).to eq(nil)
          expect(data_mapper.cleaned).to eq(nil)
          @yielded = true
        end
        expect(active_record.cleaned).to eq(true)
        expect(data_mapper.cleaned).to eq(true)
      end

      it "should proxy clean_with to all connections" do
        stratagem = double("stratgem")
        expect(active_record).to receive(:clean_with).with(stratagem)
        expect(data_mapper).to receive(:clean_with).with(stratagem)

        DatabaseCleaner.clean_with stratagem
      end
    end

    # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could
    # plausably want to force orm/strategy change on two sets of orm that differ only on db
    context "multiple orm proxy methods" do

      pending "should proxy orm to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_on_db_one").as_null_object
        active_record_2 = double("active_mock_on_db_two").as_null_object
        data_mapper_1   = double("data_mock_on_db_one").as_null_object

        DatabaseCleaner.connections_stub [active_record_1,active_record_2,data_mapper_1]

        expect(active_record_1).to receive(:orm=).with(:data_mapper)
        expect(active_record_2).to receive(:orm=).with(:data_mapper)
        expect(data_mapper_1).to receive(:orm=).with(:data_mapper)

        expect(active_record_1).to receive(:==).with(data_mapper_1).and_return(true)

        expect(DatabaseCleaner.connections.size).to eq 3
        DatabaseCleaner.orm = :data_mapper
        expect(DatabaseCleaner.connections.size).to eq 2
      end

      it "should proxy strategy to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_strategy_one").as_null_object
        active_record_2 = double("active_mock_strategy_two").as_null_object
        strategy = double("strategy")

        DatabaseCleaner.connections_stub [active_record_1,active_record_2]

        expect(active_record_1).to receive(:strategy=).with(strategy)
        expect(active_record_2).to receive(:strategy=).with(strategy)

        expect(active_record_1).to receive(:==).with(active_record_2).and_return(true)

        expect(DatabaseCleaner.connections.size).to eq 2
        DatabaseCleaner.strategy = strategy
        expect(DatabaseCleaner.connections.size).to eq 1
      end
    end
  end

  describe "remove_duplicates" do
    it "should remove duplicates if they are identical" do
      orm = double("orm")
      connection = double("a datamapper connection", :orm => orm )

      DatabaseCleaner.connections_stub  [connection,connection,connection]

      DatabaseCleaner.remove_duplicates
      expect(DatabaseCleaner.connections.size).to eq 1
    end
  end

  describe "app_root" do
    it "should default to Dir.pwd" do
      expect(DatabaseCleaner.app_root).to eq Dir.pwd
    end

    it "should store specific paths" do
      DatabaseCleaner.app_root = '/path/to'
      expect(DatabaseCleaner.app_root).to eq '/path/to'
    end
  end

  describe "orm_module" do
    subject { DatabaseCleaner }

    let(:mod) { double }

    it "should return DatabaseCleaner::ActiveRecord for :active_record" do
      stub_const "DatabaseCleaner::ActiveRecord", mod
      expect(subject.orm_module(:active_record)).to eq mod
    end

    it "should return DatabaseCleaner::DataMapper for :data_mapper" do
      stub_const "DatabaseCleaner::DataMapper", mod
      expect(subject.orm_module(:data_mapper)).to eq mod
    end

    it "should return DatabaseCleaner::MongoMapper for :mongo_mapper" do
      stub_const "DatabaseCleaner::MongoMapper", mod
      expect(subject.orm_module(:mongo_mapper)).to eq mod
    end

    it "should return DatabaseCleaner::Mongoid for :mongoid" do
      stub_const "DatabaseCleaner::Mongoid", mod
      expect(subject.orm_module(:mongoid)).to eq mod
    end

    it "should return DatabaseCleaner::Mongo for :mongo" do
      stub_const "DatabaseCleaner::Mongo", mod
      expect(subject.orm_module(:mongo)).to eq mod
    end

    it "should return DatabaseCleaner::CouchPotato for :couch_potato" do
      stub_const "DatabaseCleaner::CouchPotato", mod
      expect(subject.orm_module(:couch_potato)).to eq mod
    end

    it "should return DatabaseCleaner::Neo4j for :neo4j" do
      stub_const "DatabaseCleaner::Neo4j", mod
      expect(subject.orm_module(:neo4j)).to eq mod
    end
  end
end
