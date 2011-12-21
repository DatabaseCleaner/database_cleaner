require 'spec_helper'
require 'database_cleaner/ohm/base'
require 'database_cleaner/shared_strategy_spec'

require 'ohm'

module DatabaseCleaner
  describe Ohm do
    it { should respond_to(:available_strategies) }
  end

  module Ohm
    class ExampleStrategy
      include ::DatabaseCleaner::Ohm::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it { should respond_to(:db) }
      it { should respond_to(:db=) }

      it "should store my describe db" do
        subject.db = :my_db
        subject.db.should == :my_db
      end

      it "should default to :default" do
        subject.db.should == :default
      end
    end
  end
end
