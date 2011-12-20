require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/base'
require 'database_cleaner/shared_strategy_spec'

class FakeModel
  def self.connection
    :fake_connection
  end
end

module DatabaseCleaner
  module ActiveRecord
    class ExampleStrategy
      include ::DatabaseCleaner::ActiveRecord::Base
    end

    describe ExampleStrategy do

      it_should_behave_like "a generic strategy"


      describe "#connection" do
        it "returns the connection from ActiveRecord::Base by default" do
          ::ActiveRecord::Base.stub!(:connection).and_return(:fake_connection)
          subject.connection.should == :fake_connection
        end

        it "returns the connection of the model provided" do
          subject.db = FakeModel
          subject.connection.should == :fake_connection
        end

        it "allows for the model to be passed in as a string" do
          subject.db = "FakeModel"
          subject.connection.should == :fake_connection
        end
      end
    end
  end
end
