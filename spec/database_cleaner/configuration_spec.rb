RSpec.describe DatabaseCleaner::Cleaners do
  subject(:cleaners) { described_class.new }

  context "orm specification" do
    it "should not accept nil orms" do
      expect { cleaners[nil] }.to raise_error(ArgumentError)
    end

    it "should accept :active_record" do
      cleaner = cleaners[:active_record]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(cleaners.values).to eq [cleaner]
    end

    it "should accept multiple orm's" do
      cleaners_values = [cleaners[:couch_potato], cleaners[:data_mapper]]
      expect(cleaners.values.map(&:orm)).to eq [:couch_potato, :data_mapper]
      expect(cleaners.values).to eq cleaners_values
    end

    it "should accept a connection parameter and store it" do
      cleaner = cleaners[:active_record, connection: :first_connection]
      expect(cleaner).to be_a(DatabaseCleaner::Base)
      expect(cleaner.orm).to eq :active_record
      expect(cleaner.db).to eq :first_connection
    end

    it "should accept multiple connections for a single orm" do
      cleaners[:data_mapper, connection: :first_db]
      cleaners[:data_mapper, connection: :second_db]
      expect(cleaners.values.map(&:orm)).to eq [:data_mapper, :data_mapper]
      expect(cleaners.values.map(&:db)).to eq [:first_db, :second_db]
    end

    it "should accept multiple connections and multiple orms" do
      cleaners[:data_mapper,   connection: :first_db ]
      cleaners[:active_record, connection: :second_db]
      cleaners[:active_record, connection: :first_db ]
      cleaners[:data_mapper,   connection: :second_db]
      expect(cleaners.values.map(&:orm)).to eq [:data_mapper, :active_record, :active_record, :data_mapper]
      expect(cleaners.values.map(&:db)).to eq [:first_db, :second_db, :first_db, :second_db]
    end

    it "should retrieve a db rather than create a new one" do
      class_double("DatabaseCleaner::ActiveRecord").as_stubbed_const
      strategy_class = class_double("DatabaseCleaner::ActiveRecord::Truncation").as_stubbed_const
      allow(strategy_class).to receive(:new)

      cleaner = cleaners[:active_record]
      cleaners[:active_record].strategy = :truncation
      expect(cleaners[:active_record]).to equal cleaner
    end
  end

  context "top level api methods" do
    context "single orm single connection" do
      let(:cleaner) { cleaners[:active_record] }

      it "should proxy strategy=" do
        stratagem = double("stratagem")
        expect(cleaner).to receive(:strategy=).with(stratagem)
        cleaners.strategy = stratagem
      end

      it "should proxy orm=" do
        orm = double("orm")
        expect(cleaner).to receive(:orm=).with(orm)
        cleaners.orm = orm
      end

      it "should proxy start" do
        expect(cleaner).to receive(:start)
        cleaners.start
      end

      it "should proxy clean" do
        expect(cleaner).to receive(:clean)
        cleaners.clean
      end

      it 'should proxy cleaning' do
        expect(cleaner).to receive(:cleaning)
        cleaners.cleaning { }
      end

      it "should proxy clean_with" do
        stratagem = double("stratgem")
        expect(cleaner).to receive(:clean_with).with(stratagem, {})
        cleaners.clean_with stratagem, {}
      end
    end

    context "multiple cleaners" do
      # these are relatively simple, all we need to do is make sure all cleaners are cleaned/started/cleaned_with appropriately.
      context "simple proxy methods" do

        let(:active_record) { double("active_mock") }
        let(:data_mapper)   { double("data_mock")   }

        subject(:cleaners) do
          DatabaseCleaner::Cleaners.new({
            active_record: active_record,
            data_mapper: data_mapper,
          })
        end

        it "should proxy orm to all cleaners" do
          expect(active_record).to receive(:orm=)
          expect(data_mapper).to receive(:orm=)

          cleaners.orm = :orm
        end

        it "should proxy start to all cleaners" do
          expect(active_record).to receive(:start)
          expect(data_mapper).to receive(:start)

          cleaners.start
        end

        it "should proxy clean to all cleaners" do
          expect(active_record).to receive(:clean)
          expect(data_mapper).to receive(:clean)

          cleaners.clean
        end

        it "should proxy clean_with to all cleaners" do
          stratagem = double("stratgem")
          expect(active_record).to receive(:clean_with).with(stratagem)
          expect(data_mapper).to receive(:clean_with).with(stratagem)

          cleaners.clean_with stratagem
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
          cleaners.cleaning do
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

      # ah now we have some difficulty, we mustn't allow duplicate cleaners to exist, but they could
      # plausably want to force orm/strategy change on two sets of orm that differ only on db
      context "multiple orm proxy methods" do
        class FakeStrategy < Struct.new(:orm, :db, :strategy); end

        context "with differing orms and dbs" do
          let(:active_record_1) { FakeStrategy.new(:active_record) }
          let(:active_record_2) { FakeStrategy.new(:active_record, :different) }
          let(:data_mapper_1)   { FakeStrategy.new(:data_mapper) }

          subject(:cleaners) do
            DatabaseCleaner::Cleaners.new({
              active_record_1: active_record_1,
              active_record_2: active_record_2,
              data_mapper_1: data_mapper_1,
            })
          end

          it "should proxy #orm= to all cleaners and remove duplicate cleaners" do
            expect { cleaners.orm = :data_mapper }
              .to change { cleaners.values }
              .from([active_record_1,active_record_2,data_mapper_1])
              .to([active_record_1,active_record_2])
          end
        end

        context "with differing strategies" do
          let(:active_record_1) { FakeStrategy.new(:active_record, :default, :truncation) }
          let(:active_record_2) { FakeStrategy.new(:active_record, :default, :transaction) }

          subject(:cleaners) do
            DatabaseCleaner::Cleaners.new({
              active_record_1: active_record_1,
              active_record_2: active_record_2,
            })
          end

          it "should proxy #strategy= to all cleaners and remove duplicate cleaners" do
            expect { cleaners.strategy = :truncation }
              .to change { cleaners.values }
              .from([active_record_1,active_record_2])
              .to([active_record_1])
          end
        end
      end
    end
  end
end
