require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/couch_potato/truncation'

module DatabaseCleaner
  module CouchPotato

    describe Truncation do
      
      #doing the require in the file root breaks autospec, doing it before(:all) just fails the specs
      before(:all) do
        #pend the specs if CouchPotato is missing
        if defined?(::CouchPotato)
          require 'couch_potato'
        end
      end  
                                                 
      let (:database) { mock('database') }
      before(:each) do
        #pend the specs if CouchPotato is missing
        pending "Please install couchdb and couch_potato before running these specs" unless defined?(::CouchPotato) 
        ::CouchPotato.stub!(:couchrest_database).and_return(database)
      end

      it "should re-create the database" do
        database.should_receive(:recreate!)

        Truncation.new.clean
      end

      it "should raise an error when the :only option is used" do
        running {
          Truncation.new(:only => ['document-type'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when the :except option is used" do
        running {
          Truncation.new(:except => ['document-type'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when invalid options are provided" do
        running {
          Truncation.new(:foo => 'bar')
        }.should raise_error(ArgumentError)
      end
    end

  end
end
