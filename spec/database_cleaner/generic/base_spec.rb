require 'spec_helper'
require 'database_cleaner/shared_strategy'
require 'database_cleaner/generic/base'
require 'active_record'

module ::DatabaseCleaner
  module Generic
    class ExampleStrategy
      include ::DatabaseCleaner::Generic::Base

      def start; end
    end

    describe ExampleStrategy do
      context "class methods" do
        subject { ExampleStrategy }

        describe "#available_strategies" do
          it "should have available strategies" do
            expect(subject.available_strategies).to be_empty
          end
        end
      end

      it_should_behave_like "a generic strategy"

      describe "#db" do
        it "should be :default" do
          expect(subject.db).to eql(:default)
        end
      end

      describe "#cleaning" do
        let (:connection) { double("connection") }
        let (:strategy) { ExampleStrategy.new }
        before do
          # DatabaseCleaner.strategy = :truncation
          connection.stub(:disable_referential_integrity).and_yield
          connection.stub(:database_cleaner_view_cache).and_return([])
          connection.stub(:database_cleaner_table_cache).and_return([])
          ::ActiveRecord::Base.stub(:connection).and_return(connection)
        end

        it "calls #clean even if there is an exception" do
          strategy.should_receive :clean
          expect do
            strategy.cleaning do
              raise NoMethodError
            end
          end.to raise_exception(NoMethodError)
        end

        it "calls #clean after processing the block" do
          strategy.should_receive :clean
          strategy.cleaning do
          end
        end
      end
    end
  end
end
