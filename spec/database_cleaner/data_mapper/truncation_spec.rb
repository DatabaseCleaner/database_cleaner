require 'database_cleaner/data_mapper/truncation'
require 'database_cleaner/spec'

module DatabaseCleaner
  module DataMapper
    RSpec.describe Truncation do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a generic truncation strategy"
    end
  end
end
