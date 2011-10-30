require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/base'
require 'database_cleaner/shared_strategy_spec'

module ActiveRecord
  class ExampleStrategy
    include ::DatabaseCleaner::ActiveRecord::Base
  end

  describe ExampleStrategy do
    it "should allow changing to DatabaseCleaner::ActiveRecord.config_file_location" do
      DatabaseCleaner::ActiveRecord.config_file_location = File.dirname(__FILE__) + '/db/test_database.yml'
      subject.db_config_file_path.should =~ /#{Regexp.escape('db/test_database.yml')}/
    end
  end
end
