require 'database_cleaner/couch_potato/truncation'
require 'couch_potato'

module DatabaseCleaner
  module CouchPotato

    describe Truncation do
      let(:database) { double('database') }

      before(:each) do
        allow(::CouchPotato).to receive(:couchrest_database).and_return(database)
      end

      it "should re-create the database" do
        expect(database).to receive(:recreate!)

        Truncation.new.clean
      end

      it "should raise an error when the :only option is used" do
        expect {
          Truncation.new(:only => ['document-type'])
        }.to raise_error(ArgumentError)
      end

      it "should raise an error when the :except option is used" do
        expect {
          Truncation.new(:except => ['document-type'])
        }.to raise_error(ArgumentError)
      end

      it "should raise an error when invalid options are provided" do
        expect {
          Truncation.new(:foo => 'bar')
        }.to raise_error(ArgumentError)
      end
    end

  end
end
