require 'spec_helper'
require 'database_cleaner/generic/base'

module ::DatabaseCleaner
  module Generic
    class ExampleStrategy
      include ::DatabaseCleaner::Generic::Base
    end
    
    describe ExampleStrategy do
      context "class methods" do
        subject { ExampleStrategy }
        its (:available_strategies) { should be_empty }
      end
      
      it_should_behave_like "a generic strategy"          
      
      its (:db) { should == :default }
      
      it "should raise NotImplementedError upon access of connection_klass" do
        expect { subject.connection_klass }.to raise_error NotImplementedError
      end
      
      it "should accept the desired database upon initalisation" do
        eg = ExampleStrategy.new :my_database
        eg.db.should == :my_database
      end
    end
  end
end