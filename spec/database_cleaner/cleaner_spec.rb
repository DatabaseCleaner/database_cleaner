module DatabaseCleaner
  RSpec.describe Cleaner do
    describe "comparison" do
      it "should be equal if orm and connection are the same" do
        one = Cleaner.new(:active_record, connection: :default)
        two = Cleaner.new(:active_record, connection: :default)

        expect(one).to eq two
        expect(two).to eq one
      end

      it "should not be equal if orm are not the same" do
        one = Cleaner.new(:mongo_id, connection: :default)
        two = Cleaner.new(:active_record, connection: :default)

        expect(one).not_to eq two
        expect(two).not_to eq one
      end

      it "should not be equal if connection are not the same" do
        one = Cleaner.new(:active_record, connection: :default)
        two = Cleaner.new(:active_record, connection: :other)

        expect(one).not_to eq two
        expect(two).not_to eq one
      end
    end

    describe "initialization" do
      context "db specified" do
        subject(:cleaner) { Cleaner.new(:active_record, connection: :my_db) }

        it "should store db from :connection in params hash" do
          expect(cleaner.db).to eq :my_db
        end
      end

      describe "orm" do
        it "should store orm" do
          cleaner = Cleaner.new(:a_orm)
          expect(cleaner.orm).to eq :a_orm
        end

        it "raises ArgumentError when no orm is specified" do
          expect { Cleaner.new }.to raise_error(ArgumentError)
        end
      end
    end

    describe "db" do
      subject(:cleaner) { Cleaner.new(:orm) }

      it "should default to :default" do
        expect(cleaner.db).to eq :default
      end

      it "should return any stored db value" do
        cleaner.db = :test_db
        expect(cleaner.db).to eq :test_db
      end
    end

    describe "db=" do
      subject(:cleaner) { Cleaner.new(:orm) }

      context "when strategy supports db specification" do
        it "should pass db down to its current strategy" do
          expect(cleaner.strategy).to receive(:db=).with(:a_new_db)
          cleaner.db = :a_new_db
        end
      end

      context "when strategy doesn't support db specification" do
        let(:strategy) { double(respond_to?: false) }

        before { cleaner.strategy = strategy }

        it "doesn't pass the default db down to it" do
          expect(strategy).to_not receive(:db=)
          cleaner.db = :default
        end

        it "should raise an argument error when db isn't default" do
          expect { cleaner.db = :test }.to raise_error ArgumentError
        end
      end
    end

    describe "clean_with" do
      subject(:cleaner) { Cleaner.new(:active_record) }

      let(:strategy_class) { Class.new }
      let(:strategy) { double }
      before { allow(strategy_class).to receive(:new).and_return(strategy) }

      before do
        stub_const "DatabaseCleaner::ActiveRecord::Truncation", strategy_class
      end

      it "should pass all arguments to strategy initializer" do
        expect(strategy_class).to receive(:new).with(:dollar, :amet, ipsum: "random").and_return(strategy)
        expect(strategy).to receive(:clean)
        cleaner.clean_with :truncation, :dollar, :amet, ipsum: "random"
      end

      it "should invoke clean on the created strategy" do
        expect(strategy).to receive(:clean)
        cleaner.clean_with :truncation
      end

      it "should return the created strategy" do
        expect(strategy).to receive(:clean)
        expect(cleaner.clean_with(:truncation)).to eq strategy
      end
    end

    describe "strategy=" do
      subject(:cleaner) { Cleaner.new(:active_record) }

      let(:strategy_class) { Class.new }

      before do
        orm_module = Module.new do
          def self.available_strategies
            %i[truncation transaction deletion]
          end
        end
        stub_const "DatabaseCleaner::ActiveRecord", orm_module
        stub_const "DatabaseCleaner::ActiveRecord::Truncation", strategy_class
      end

      it "should look up and create a the named strategy for the current ORM" do
        cleaner.strategy = :truncation
        expect(cleaner.strategy).to be_a(strategy_class)
      end

      it "should proxy params with symbolised strategies" do
        expect(strategy_class).to receive(:new).with(param: "one")
        cleaner.strategy = :truncation, { param: "one" }
      end

      it "should accept strategy objects" do
        strategy = double
        cleaner.strategy = strategy
        expect(cleaner.strategy).to eq strategy
      end

      it "should raise argument error when params given with strategy object" do
        expect do
          cleaner.strategy = double, { param: "one" }
        end.to raise_error ArgumentError
      end

      it "should attempt to set strategy db" do
        strategy = double
        expect(strategy).to receive(:db=).with(:default)
        cleaner.strategy = strategy
      end

      it "raises UnknownStrategySpecified on a bad strategy, and lists available strategies" do
        expect { cleaner.strategy = :horrible_plan }.to \
          raise_error(UnknownStrategySpecified, "The 'horrible_plan' strategy does not exist for the active_record ORM!  Available strategies: truncation, transaction, deletion")
      end
    end

    describe "strategy" do
      subject(:cleaner) { Cleaner.new(:a_orm) }

      it "returns a null strategy when strategy is not set and undetectable" do
        expect(cleaner.strategy).to be_a(DatabaseCleaner::NullStrategy)
      end
    end

    describe "proxy methods" do
      subject(:cleaner) { Cleaner.new(:orm) }

      let(:strategy) { double(:strategy) }

      before { cleaner.strategy = strategy }

      describe "start" do
        it "should proxy start to the strategy" do
          expect(strategy).to receive(:start)
          cleaner.start
        end
      end

      describe "clean" do
        it "should proxy clean to the strategy" do
          expect(strategy).to receive(:clean)
          cleaner.clean
        end
      end

      describe "cleaning" do
        it "should proxy cleaning to the strategy" do
          expect(strategy).to receive(:cleaning)
          cleaner.cleaning { }
        end
      end
    end
  end
end
