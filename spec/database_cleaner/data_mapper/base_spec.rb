require 'spec_helper'
require 'database_cleaner/data_mapper/base'
require 'database_cleaner/shared_strategy'

module DatabaseCleaner
  describe DataMapper do
    it { is_expected.to respond_to(:available_strategies) }
  end

  module DataMapper
    class ExampleStrategy
      include ::DatabaseCleaner::DataMapper::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it { is_expected.to respond_to(:db)  }
      it { is_expected.to respond_to(:db=) }

      it "should store my desired db" do
        subject.db = :my_db
        expect(subject.db).to eq :my_db
      end

      it "should default to :default" do
        expect(subject.db).to eq :default
      end
    end
  end
end
