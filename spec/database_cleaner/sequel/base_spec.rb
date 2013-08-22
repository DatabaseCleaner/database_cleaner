require 'spec_helper'
require 'database_cleaner/sequel/base'
require 'database_cleaner/shared_strategy'
require 'sequel'

module DatabaseCleaner
  describe Sequel do
    it { should respond_to(:available_strategies) }
  end

  module Sequel
    class ExampleStrategy
      include ::DatabaseCleaner::Sequel::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it { should respond_to(:db)  }
      it { should respond_to(:db=) }

      it "should store my desired db" do
        subject.db = :my_db
        subject.db.should eq :my_db
      end

      it "should default to :default" do
        pending "I figure out how to use Sequel and write some real tests for it..."
        subject.db.should eq :default
      end
    end
  end
end
