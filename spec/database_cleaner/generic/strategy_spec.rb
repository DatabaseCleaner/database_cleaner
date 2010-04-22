require 'spec_helper'
require 'database_cleaner/generic/strategy'

module ::DatabaseCleaner
  module Generic
    class ExtendedStrategy
      include Strategy
    end
    
    describe ExtendedStrategy do
      context "class methods" do
        subject { ExtendedStrategy }
        its (:available_strategies) { should be_empty }
      end
      
      it { should respond_to :db  }
      it { should respond_to :db= }
      it { should respond_to :connection_klass }
      
      its (:db) { should == :default }
      
      it "should raise NotImplementedError upon access of connection_klass" do
        expect { subject.connection_klass }.to raise_error NotImplementedError
      end
      
      it "should accept the desired database upon initalisation" do
        eg = ExtendedStrategy.new :my_database
        eg.db.should == :my_database
      end
    end
  end
end