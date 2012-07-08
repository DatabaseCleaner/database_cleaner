require 'spec_helper'
require 'database_cleaner/sequel/transaction'
require 'database_cleaner/shared_strategy'
require 'sequel'

module DatabaseCleaner
  module Sequel
    describe Transaction do
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
