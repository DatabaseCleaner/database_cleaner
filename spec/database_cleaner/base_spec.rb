module DatabaseCleaner
  RSpec.describe Base do
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

        it "should default to nil" do
          expect(subject.orm).to be_nil
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
      subject { described_class.new(:active_record) }

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

      let(:strategy) { double }

      before do
        allow(strategy_class).to receive(:new).and_return(strategy)
      end

      it "should pass all arguments to strategy initializer" do
        expect(strategy_class).to receive(:new).with(:dollar, :amet, ipsum: "random").and_return(strategy)
        expect(strategy).to receive(:clean)
        subject.clean_with :truncation, :dollar, :amet, ipsum: "random"
      end

      it "should invoke clean on the created strategy" do
        expect(strategy).to receive(:clean)
        subject.clean_with :truncation
      end

      it "should return the created strategy" do
        expect(strategy).to receive(:clean)
        expect(subject.clean_with(:truncation)).to eq strategy
      end
    end

    describe "strategy=" do
      subject { described_class.new(:active_record) }

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
  end
end
