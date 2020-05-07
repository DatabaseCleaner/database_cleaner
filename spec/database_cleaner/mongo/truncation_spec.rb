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

    context "when new collection is created after clean" do
      before do
        subject.clean

        MongoTest::Gizmo.new(name: 'some gizmo').save!
      end

      it "truncates new collection" do
        expect { subject.clean }.to change {
          MongoTest::Gizmo.count
        }.from(1).to(0)
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
end

