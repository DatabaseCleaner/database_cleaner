require 'spec_helper'
require 'database_cleaner/data_mapper/base'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  describe DataMapper do
    it { should respond_to :available_strategies }
  end                
  
  module DataMapper
    class ExampleStrategy
      include ::DatabaseCleaner::DataMapper::Base
    end                                      

    describe ExampleStrategy do
      it_should_behave_like "a generic strategy"
      #it { expect{ subject.connection_klass }.to_not raise_error }
    end
  end
end