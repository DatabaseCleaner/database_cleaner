require 'spec_helper'
require 'database_cleaner/mongo_mapper/base'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  describe MongoMapper do
    it { should respond_to(:available_strategies) }
  end

  module MongoMapper
    class ExampleStrategy
      include ::DatabaseCleaner::MongoMapper::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a strategy with configurable db"
    end
  end
end
