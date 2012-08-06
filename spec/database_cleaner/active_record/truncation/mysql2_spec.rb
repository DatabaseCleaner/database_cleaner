require 'spec_helper'
require 'active_record'
require 'support/active_record/mysql2_setup'
require 'database_cleaner/active_record/truncation'
require 'database_cleaner/active_record/truncation/shared_fast_truncation'

module ActiveRecord
  module ConnectionAdapters
    describe do 
      before(:all) { active_record_mysql2_setup }

      let(:adapter) { Mysql2Adapter }
      let(:connection) { active_record_mysql2_connection }

      describe "#truncate_table" do
        it "should truncate the table" do
          2.times { User.create }

          connection.truncate_table('users')
          User.count.should == 0
        end

        it "should reset AUTO_INCREMENT index of table" do
          2.times { User.create }
          User.delete_all

          connection.truncate_table('users')

          User.create.id.should == 1
        end
      end

      it_behaves_like "an adapter with pre-count truncation" do
        let(:adapter) { Mysql2Adapter }
        let(:connection) { active_record_mysql2_connection }
      end
    end
  end
end

