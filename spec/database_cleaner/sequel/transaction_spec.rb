require 'database_cleaner/sequel/transaction'
require 'database_cleaner/spec'
require 'support/sequel_helper'

module DatabaseCleaner
  module Sequel
    RSpec.describe Transaction do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a generic transaction strategy"

      describe "start" do
        it "should start a transaction"
      end

      describe "clean" do
        it "should finish a transaction"
      end
    end
  end
end
