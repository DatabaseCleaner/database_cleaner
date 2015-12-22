require 'spec_helper'
require 'redis'
require 'database_cleaner/redis/base'
require 'database_cleaner/shared_strategy'

module DatabaseCleaner
  describe Redis do
    it { should respond_to(:available_strategies) }
  end

  module Redis
    class ExampleStrategy
      include ::DatabaseCleaner::Redis::Base
    end

    describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { should respond_to(:db) }
      it { should respond_to(:db=) }

      context "when passing url" do
        it "should store my describe db" do
          url = 'redis://localhost:6379/2'
          subject.db = 'redis://localhost:6379/2'
          subject.db.should eq url
        end
      end

      context "when passing connection" do
        it "should store my describe db" do
          connection = ::Redis.new :url => 'redis://localhost:6379/2'
          subject.db = connection
          subject.db.should eq connection
        end
      end

      it "should default to :default" do
        subject.db.should eq :default
      end
    end
  end
end
