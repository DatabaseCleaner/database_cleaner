require 'mongo_mapper'
require 'database_cleaner/mongo_mapper/truncation'
require File.dirname(__FILE__) + '/mongo_examples'

describe DatabaseCleaner::MongoMapper::Truncation do
  around do |example|
    MongoMapper.connection = Mongo::Connection.new('127.0.0.1')
    db_name = 'database_cleaner_specs'
    MongoMapper.database = db_name

    example.run

    MongoMapper.connection.drop_database(db_name)
  end

  before do
    MongoMapperTest::Widget.new(name: 'some widget').save!
    MongoMapperTest::Gadget.new(name: 'some gadget').save!
  end

  context "by default" do
    it "truncates all collections" do
      expect { subject.clean }.to change {
        [MongoMapperTest::Widget.count, MongoMapperTest::Gadget.count]
      }.from([1,1]).to([0,0])
    end
  end

  context "when collections are provided to the :only option" do
    subject { described_class.new(only: ['mongo_mapper_test.widgets']) }

    it "only truncates the specified collections" do
      expect { subject.clean }.to change {
        [MongoMapperTest::Widget.count, MongoMapperTest::Gadget.count]
      }.from([1,1]).to([0,1])
    end
  end

  context "when collections are provided to the :except option" do
    subject { described_class.new(except: ['mongo_mapper_test.widgets']) }

    it "truncates all but the specified collections" do
      expect { subject.clean }.to change {
        [MongoMapperTest::Widget.count, MongoMapperTest::Gadget.count]
      }.from([1,1]).to([1,0])
    end
  end
end

