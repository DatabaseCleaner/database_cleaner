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

    it "should default to autodetection" do
      require "active_record"
      cleaner = subject.connections.first
      expect(cleaner.orm).to eq :active_record
    end

    it "should accept :active_record" do
      cleaner = subject[:active_record]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(subject.connections).to eq [cleaner]
    end

    it "should accept :data_mapper" do
      cleaner = subject[:data_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :data_mapper
      expect(subject.connections).to eq [cleaner]
    end

    it "should accept :mongo_mapper" do
      cleaner = subject[:mongo_mapper]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :mongo_mapper
      expect(subject.connections).to eq [cleaner]
    end

    it "should accept :couch_potato" do
      cleaner = subject[:couch_potato]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :couch_potato
      expect(subject.connections).to eq [cleaner]
    end

    it "should accept :moped" do
      cleaner = subject[:moped]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :moped
      expect(subject.connections).to eq [cleaner]
    end

    it 'accepts :ohm' do
      cleaner = subject[:ohm]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :ohm
      expect(subject.connections).to eq [cleaner]
    end

    it "should accept multiple orm's" do
      cleaners = [subject[:couch_potato], subject[:data_mapper]]
      expect(subject.connections.map(&:orm)).to eq [:couch_potato, :data_mapper]
      expect(subject.connections).to eq cleaners
    end

    it "should accept a connection parameter and store it" do
      cleaner = subject[:active_record, connection: :first_connection]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(cleaner.db).to eq :first_connection
    end

    it "should accept multiple connections for a single orm" do
      subject[:data_mapper, connection: :first_db]
      subject[:data_mapper, connection: :second_db]
      expect(subject.connections.map(&:orm)).to eq [:data_mapper, :data_mapper]
      expect(subject.connections.map(&:db)).to eq [:first_db, :second_db]
    end

    it "should accept multiple connections and multiple orms" do
      subject[:data_mapper,   connection: :first_db ]
      subject[:active_record, connection: :second_db]
      subject[:active_record, connection: :first_db ]
      subject[:data_mapper,   connection: :second_db]
      expect(subject.connections.map(&:orm)).to eq [:data_mapper, :active_record, :active_record, :data_mapper]
      expect(subject.connections.map(&:db)).to eq [:first_db, :second_db, :first_db, :second_db]
    end

    it "should retrieve a db rather than create a new one" do
      connection = subject[:active_record]
      subject[:active_record].strategy = :truncation
      expect(subject[:active_record]).to equal connection
    end
  end

  context "top level api methods" do
    context "single orm single connection" do
      let(:connection) { subject[:active_record] }

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

        it "should proxy clean_with to all connections" do
          stratagem = double("stratgem")
          expect(active_record).to receive(:clean_with).with(stratagem)
          expect(data_mapper).to receive(:clean_with).with(stratagem)

          subject.clean_with stratagem
        end

        it "should initiate cleaning on each connection, yield, and finish cleaning each connection" do
          [active_record, data_mapper].each do |connection|
            class << connection
              attr_reader :started, :cleaned

              def cleaning &block
                @started = true
                block.call
                @cleaned = true
              end
            end
          end

          yielded = false
          subject.cleaning do
            expect(active_record.started).to eq(true)
            expect(data_mapper.started).to eq(true)
            expect(active_record.cleaned).to eq(nil)
            expect(data_mapper.cleaned).to eq(nil)
            yielded = true
          end

          expect(yielded).to eq(true)
          expect(active_record.cleaned).to eq(true)
          expect(data_mapper.cleaned).to eq(true)
        end
      end

      # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could
      # plausably want to force orm/strategy change on two sets of orm that differ only on db
      context "multiple orm proxy methods" do
        class FakeStrategy < Struct.new(:orm, :db, :strategy); end

        context "with differing orms and dbs" do
          let(:active_record_1) { FakeStrategy.new(:active_record) }
          let(:active_record_2) { FakeStrategy.new(:active_record, :different) }
          let(:data_mapper_1)   { FakeStrategy.new(:data_mapper) }

          before do
            subject.connections_stub [active_record_1,active_record_2,data_mapper_1]
          end

          it "should proxy #orm= to all connections and remove duplicate connections" do
            expect { subject.orm = :data_mapper }
              .to change { subject.connections }
              .from([active_record_1,active_record_2,data_mapper_1])
              .to([active_record_1,active_record_2])
          end
        end

        context "with differing strategies" do
          let(:active_record_1) { FakeStrategy.new(:active_record, :default, :truncation) }
          let(:active_record_2) { FakeStrategy.new(:active_record, :default, :transaction) }

          before do
            subject.connections_stub [active_record_1,active_record_2]
          end

          it "should proxy #strategy= to all connections and remove duplicate connections" do
            expect { subject.strategy = :truncation }
              .to change { subject.connections }
              .from([active_record_1,active_record_2])
              .to([active_record_1])
          end
        end
      end
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
