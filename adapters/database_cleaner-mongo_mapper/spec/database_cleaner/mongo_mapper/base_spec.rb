require 'database_cleaner/mongo_mapper/base'
require 'database_cleaner/spec'

module DatabaseCleaner
  RSpec.describe MongoMapper do
    it { is_expected.to respond_to(:available_strategies) }

    it "has a default_strategy of truncation" do
      expect(described_class.default_strategy).to eq(:truncation)
    end
  end

  module MongoMapper
    class ExampleStrategy
      include ::DatabaseCleaner::MongoMapper::Base
    end

    RSpec.describe ExampleStrategy do

      it_should_behave_like "a generic strategy"

      describe "db" do
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
end
