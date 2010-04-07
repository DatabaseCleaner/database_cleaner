require 'spec_helper'
require 'database_cleaner/active_record/adaptor'
require 'database_cleaner/shared_adaptor_spec'

 class ExampleStrategy
   include ::DatabaseCleaner::ActiveRecord::Adaptor
 end                                      

module DatabaseCleaner
  describe ActiveRecord do
    it { should respond_to :available_strategies }
  end                
  
  module ActiveRecord
    describe ExampleStrategy do
      it_should_behave_like "database cleaner adaptor"
    end
  end
end