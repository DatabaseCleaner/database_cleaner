require 'database_cleaner/neo4j/base'
require 'database_cleaner/spec'

module DatabaseCleaner
  RSpec.describe Neo4j do
    it { is_expected.to respond_to(:available_strategies) }

    it "has a default_strategy of transaction" do
      expect(described_class.default_strategy).to eq(:transaction)
    end
  end

  module Neo4j
    class ExampleStrategy
      include ::DatabaseCleaner::Neo4j::Base
    end

    RSpec.describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { is_expected.to respond_to(:db) }
      it { is_expected.to respond_to(:db=) }

      it "should store my describe db" do
        db_conf = {:connection => {:type => :server_db, :path => 'http://localhost:7474'}}
        subject.db = db_conf
        expect(subject.db).to eq db_conf
      end

      it "should respect additional connection parameters" do
        db_conf = {:type => :server_db, :path => 'http://localhost:7474', basic_auth: {username: 'user', password: 'pass'}}
        subject.db = db_conf
        expect(stub_const("Neo4j::Session", double())).to receive(:open).with(:server_db, 'http://localhost:7474', {basic_auth: {username: 'user', password: 'pass'}}) { true }
        subject.start
      end

      it "should default to nil" do
        expect(subject.db).to be_nil
      end

      it "should return default configuration" do
        expect(subject.database).to eq(:type => :server_db, :path => 'http://localhost:7475/')
      end
    end
  end
end
