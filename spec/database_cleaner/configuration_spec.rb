module ArrayHelper
  def zipmap(array, vals)
    Hash[*(array.zip(vals).flatten)]
  end
  module_function :zipmap
end

module DatabaseCleaner
  class Configuration
    # hackey, hack.. connections needs to stick around until I can properly deprecate the API
    def connections_stub(array)
      @cleaners = ArrayHelper.zipmap((1..array.size).to_a, array)
      @connections = array
    end
  end
end

RSpec.describe DatabaseCleaner::Configuration do
  context "orm specification" do
    it "should not accept unrecognised orms" do
      expect { subject[nil] }.to raise_error(DatabaseCleaner::NoORMDetected)
    end

    it "should accept :active_record" do
      cleaner = subject[:active_record]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(subject.connections.size).to eq 1
    end

    it "should accept :data_mapper" do
      cleaner = subject[:data_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :data_mapper
      expect(subject.connections.size).to eq 1
    end

    it "should accept :mongo_mapper" do
      cleaner = subject[:mongo_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :mongo_mapper
      expect(subject.connections.size).to eq 1
    end

    it "should accept :couch_potato" do
      cleaner = subject[:couch_potato]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :couch_potato
      expect(subject.connections.size).to eq 1
    end

    it "should accept :moped" do
      cleaner = subject[:moped]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :moped
      expect(subject.connections.size).to eq 1
    end

    it 'accepts :ohm' do
      cleaner = subject[:ohm]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :ohm
      expect(subject.connections.size).to eq 1
    end
  end

  it "should accept multiple orm's" do
    subject[:couch_potato]
    subject[:data_mapper]
    expect(subject.connections.size).to eq 2
    expect(subject.connections[0].orm).to eq :couch_potato
    expect(subject.connections[1].orm).to eq :data_mapper
  end

  context "connection/db specification" do
    it "should accept a connection parameter and store it" do
      cleaner = subject[:active_record, {:connection => :first_connection}]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(cleaner.db).to eq :first_connection
    end

    it "should accept multiple connections for a single orm" do
      subject[:data_mapper,{:connection => :first_db}]
      subject[:data_mapper,{:connection => :second_db}]
      expect(subject.connections.size).to eq 2
      expect(subject.connections[0].orm).to eq :data_mapper
      expect(subject.connections[0].db).to  eq :first_db
      expect(subject.connections[1].orm).to eq :data_mapper
      expect(subject.connections[1].db).to  eq :second_db
    end

    it "should accept multiple connections and multiple orms" do
      subject[:data_mapper,  {:connection => :first_db} ]
      subject[:active_record,{:connection => :second_db}]
      subject[:active_record,{:connection => :first_db} ]
      subject[:data_mapper,  {:connection => :second_db}]

      expect(subject.connections.size).to eq 4

      expect(subject.connections[0].orm).to eq :data_mapper
      expect(subject.connections[0].db).to  eq :first_db

      expect(subject.connections[1].orm).to eq :active_record
      expect(subject.connections[1].db).to  eq :second_db

      expect(subject.connections[2].orm).to eq :active_record
      expect(subject.connections[2].db).to  eq :first_db

      expect(subject.connections[3].orm).to eq :data_mapper
      expect(subject.connections[3].db).to  eq :second_db
    end
  end

  context "connection/db retrieval" do
    it "should retrieve a db rather than create a new one" do
      connection = subject[:active_record]
      subject[:active_record].strategy = :truncation
      expect(subject[:active_record]).to equal connection
    end
  end

  context "class methods" do
    it "should give me a default (autodetection) databasecleaner by default" do
      cleaner = double("cleaner").as_null_object
      allow(DatabaseCleaner::Base).to receive(:new).and_return(cleaner)

      expect(subject.connections).to eq [cleaner]
    end
  end

  context "single orm single connection" do
    let(:connection) { double}

    before do
      subject.connections_stub([connection])
    end

    it "should proxy strategy=" do
      stratagem = double("stratagem")
      expect(connection).to receive(:strategy=).with(stratagem)
      subject.strategy = stratagem
    end

    it "should proxy orm=" do
      orm = double("orm")
      expect(connection).to receive(:orm=).with(orm)
      subject.orm = orm
    end

    it "should proxy start" do
      expect(connection).to receive(:start)
      subject.start
    end

    it "should proxy clean" do
      expect(connection).to receive(:clean)
      subject.clean
    end

    it 'should proxy cleaning' do
      expect(connection).to receive(:cleaning)
      subject.cleaning { }
    end

    it "should proxy clean_with" do
      stratagem = double("stratgem")
      expect(connection).to receive(:clean_with).with(stratagem, {})
      subject.clean_with stratagem, {}
    end
  end

  context "multiple connections" do

    # these are relatively simple, all we need to do is make sure all connections are cleaned/started/cleaned_with appropriately.
    context "simple proxy methods" do

      let(:active_record) { double("active_mock") }
      let(:data_mapper)   { double("data_mock")   }

      before do
        subject.connections_stub([active_record,data_mapper])
      end

      it "should proxy orm to all connections" do
        expect(active_record).to receive(:orm=)
        expect(data_mapper).to receive(:orm=)

        subject.orm = double("orm")
      end

      it "should proxy start to all connections" do
        expect(active_record).to receive(:start)
        expect(data_mapper).to receive(:start)

        subject.start
      end

      it "should proxy clean to all connections" do
        expect(active_record).to receive(:clean)
        expect(data_mapper).to receive(:clean)

        subject.clean
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

        subject.cleaning do
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

        subject.clean_with stratagem
      end
    end

    # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could
    # plausably want to force orm/strategy change on two sets of orm that differ only on db
    context "multiple orm proxy methods" do

      it "should proxy orm to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_on_db_one").as_null_object
        active_record_2 = double("active_mock_on_db_two").as_null_object
        data_mapper_1   = double("data_mock_on_db_one").as_null_object

        subject.connections_stub [active_record_1,active_record_2,data_mapper_1]

        expect(active_record_1).to receive(:orm=).with(:data_mapper)
        expect(active_record_2).to receive(:orm=).with(:data_mapper)
        expect(data_mapper_1).to receive(:orm=).with(:data_mapper)

        expect(active_record_1).to receive(:==).with(active_record_2).and_return(false)
        expect(active_record_2).to receive(:==).with(data_mapper_1).and_return(false)
        expect(active_record_1).to receive(:==).with(data_mapper_1).and_return(true)

        expect(subject.connections.size).to eq 3
        subject.orm = :data_mapper
        expect(subject.connections.size).to eq 2
      end

      it "should proxy strategy to all connections and remove duplicate connections" do
        active_record_1 = double("active_mock_strategy_one").as_null_object
        active_record_2 = double("active_mock_strategy_two").as_null_object
        strategy = double("strategy")

        subject.connections_stub [active_record_1,active_record_2]

        expect(active_record_1).to receive(:strategy=).with(strategy)
        expect(active_record_2).to receive(:strategy=).with(strategy)

        expect(active_record_1).to receive(:==).with(active_record_2).and_return(true)

        expect(subject.connections.size).to eq 2
        subject.strategy = strategy
        expect(subject.connections.size).to eq 1
      end
    end
  end

  describe "remove_duplicates" do
    it "should remove duplicates if they are identical" do
      orm = double("orm")
      connection = double("a datamapper connection", :orm => orm )

      subject.connections_stub  [connection,connection,connection]

      subject.remove_duplicates
      expect(subject.connections.size).to eq 1
    end
  end

  describe "app_root" do
    it "should default to Dir.pwd" do
      expect(subject.app_root).to eq Dir.pwd
    end

    it "should store specific paths" do
      subject.app_root = '/path/to'
      expect(subject.app_root).to eq '/path/to'
    end
  end
end
