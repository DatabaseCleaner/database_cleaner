require 'database_cleaner/sequel/base'
require 'database_cleaner/shared_strategy'
require 'sequel'

module DatabaseCleaner
  RSpec.describe Sequel do
    it { is_expected.to respond_to(:available_strategies) }
  end

  module Sequel
    class ExampleStrategy
      include ::DatabaseCleaner::Sequel::Base
    end

    RSpec.describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it { is_expected.to respond_to(:db)  }
      it { is_expected.to respond_to(:db=) }

      it "should store my desired db" do
        subject.db = :my_db
        expect(subject.db).to eq :my_db
      end

      pending "I figure out how to use Sequel and write some real tests for it..."
    end
  end
end
