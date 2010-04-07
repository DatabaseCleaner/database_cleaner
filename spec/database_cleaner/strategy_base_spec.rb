require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/strategy_base'
#require 'database_cleaner/active_record/transaction'
#require 'database_cleaner/data_mapper/transaction'

class ExampleStrategy
  include ::DatabaseCleaner::StrategyBase
end

module DatabaseCleaner
  describe StrategyBase do

    context "upon inclusion" do
      subject { ExampleStrategy.new }
      
      it "should add the db setter method" do
        should respond_to :db=
      end
      
      its(:db) { should == :default }

      it "should store a symbol representing the db to use" do
        subject.db = :my_specific_connection
        subject.db.should == :my_specific_connection
      end
    end
  end
end