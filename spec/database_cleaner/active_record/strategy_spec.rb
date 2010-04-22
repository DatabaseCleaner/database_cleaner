require 'spec_helper'
require 'database_cleaner/active_record/strategy'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  describe ActiveRecord do
    it { should respond_to :available_strategies }
  end                
  
  module ActiveRecord 
    class ExampleStrategy
      include ::DatabaseCleaner::ActiveRecord::Strategy
    end                                      

    describe ExampleStrategy do
      it_should_behave_like "database cleaner strategy"
      it { expect{ subject.connection_klass }.to_not raise_error }
    end
  end
end