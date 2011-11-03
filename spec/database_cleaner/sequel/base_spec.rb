require 'spec_helper'
require 'database_cleaner/sequel/base'
require 'database_cleaner/shared_strategy_spec'
require 'sequel'

module DatabaseCleaner
  describe Sequel do
    it { should respond_to(:available_strategies) }
  end

  module Sequel
    class ExampleStrategy
      include ::DatabaseCleaner::Sequel::Base
    end

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
    end
  end
end
