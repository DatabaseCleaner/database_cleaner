require 'mongo'
require 'database_cleaner/mongo/truncation'
require File.dirname(__FILE__) + '/mongo_examples'

RSpec.describe DatabaseCleaner::Mongo::Truncation do
  around do |example|
    connection = Mongo::Connection.new('127.0.0.1')
    db_name = 'database_cleaner_specs'
    db = connection.db(db_name)
    subject.db = db

    example.run

    connection.drop_database(db_name)
  end

  before do
    MongoTest::Widget.new(name: 'some widget').save!
    MongoTest::Gadget.new(name: 'some gadget').save!
  end

  describe "#clean" do
    context "by default" do
      it "truncates all collections" do
        expect { subject.clean }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([0,0])
      end
    end

    context "when collections are provided to the :only option" do
      subject { described_class.new(only: ['MongoTest::Widget']) }

      it "only truncates the specified collections" do
        expect { subject.clean }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([0,1])
      end
    end

    context "when collections are provided to the :except option" do
      subject { described_class.new(except: ['MongoTest::Widget']) }

      it "truncates all but the specified collections" do
        expect { subject.clean }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([1,0])
      end
    end
  end

  describe "#cleaning" do
    context "by default" do
      it "truncates all collections" do
        expect { subject.cleaning {} }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([0,0])
      end
    end

    context "when collections are provided to the :only option" do
      subject { described_class.new(only: ['MongoTest::Widget']) }

      it "only truncates the specified collections" do
        expect { subject.cleaning {} }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([0,1])
      end
    end

    context "when collections are provided to the :except option" do
      subject { described_class.new(except: ['MongoTest::Widget']) }

      it "truncates all but the specified collections" do
        expect { subject.cleaning {} }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([1,0])
      end
    end
  end

  describe ":cache_tables option" do
    describe "unset" do
      it "does not clean collections created after instantiation" do
        subject.clean
        MongoTest::Base.new(name: 'test').save!
        subject.clean
        expect([MongoTest::Widget.count, MongoTest::Gadget.count, MongoTest::Base.count]).to eq([0,0,1])
      end
    end

    describe "set to true" do
      it "does not clean collections created after instantiation" do
        db = subject.db
        subject = described_class.new(cache_tables: true)
        subject.db = db
        subject.clean
        MongoTest::Base.new(name: 'test').save!
        subject.clean
        expect([MongoTest::Widget.count, MongoTest::Gadget.count, MongoTest::Base.count]).to eq([0,0,1])
      end
    end

    describe "set to false" do
      it "cleans all collections, even those created after instantiation" do
        db = subject.db
        subject = described_class.new(cache_tables: false)
        subject.db = db
        subject.clean
        MongoTest::Base.new(name: 'test').save!
        subject.clean
        expect([MongoTest::Widget.count, MongoTest::Gadget.count, MongoTest::Base.count]).to eq([0,0,0])
      end
    end
  end
end

