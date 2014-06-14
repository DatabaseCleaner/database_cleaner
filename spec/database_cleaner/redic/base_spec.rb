require 'spec_helper'
require 'database_cleaner/redic/base'
require 'database_cleaner/shared_strategy'

module DatabaseCleaner
  describe Redic do
    it { should respond_to(:available_strategies) }
  end

  module Redic
    class ExampleStrategy
      include ::DatabaseCleaner::Redic::Base
    end

    describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { should respond_to(:db) }
      it { should respond_to(:db=) }

      it "should store my describe db" do
        url = 'redis://localhost:6379/2'
        subject.db = 'redis://localhost:6379/2'
        subject.db.should eq url
      end

      it "should default to :default" do
        subject.db.should eq :default
      end
    end
  end
end
