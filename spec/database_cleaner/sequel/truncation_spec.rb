require 'spec_helper'
require 'database_cleaner/sequel/truncation'
require 'database_cleaner/shared_strategy'
require 'sequel'

module DatabaseCleaner
  module Sequel
    describe Truncation do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a generic truncation strategy"
    end
  end
end
