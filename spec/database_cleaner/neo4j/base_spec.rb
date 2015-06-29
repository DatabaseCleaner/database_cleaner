require 'spec_helper'
require 'database_cleaner/neo4j/base'
require 'database_cleaner/shared_strategy'

module DatabaseCleaner
  describe Neo4j do
    it { should respond_to(:available_strategies) }
  end

  module Neo4j
    class ExampleStrategy
      include ::DatabaseCleaner::Neo4j::Base
    end

    describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { should respond_to(:db) }
      it { should respond_to(:db=) }

      it "should store my describe db" do
        db_conf = {:connection => {:type => :server_db, :path => 'http://localhost:7474'}}
        subject.db = db_conf
        subject.db.should eq db_conf
      end

      it "should respect additional connection parameters" do
        db_conf = {:type => :server_db, :path => 'http://localhost:7474', basic_auth: {username: 'user', password: 'pass'}}
        subject.db = db_conf
        stub_const("Neo4j::Session", double()).should_receive(:open).with(:server_db, 'http://localhost:7474', {basic_auth: {username: 'user', password: 'pass'}}) { true }
        subject.start
      end

      it "should default to nil" do
        subject.db.should be_nil
      end

      it "should return default configuration" do
        subject.database.should eq(:type => :server_db, :path => 'http://localhost:7475/')
      end
    end
  end
end
