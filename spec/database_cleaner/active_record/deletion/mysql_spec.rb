require 'spec_helper'
require 'active_record'
require 'support/active_record/mysql_setup'
require 'database_cleaner/active_record/deletion'

module ActiveRecord
  module AbstractMysqlAdapter
    describe do
      before(:all) { active_record_mysql_setup }

      let(:connection) { active_record_mysql_connection }

      describe "#delete_table" do
        it "should delete the table" do
          2.times { User.create }
          DatabaseCleaner::ActiveRecord::Deletion.new.clean

          User.count.should eq 0
        end
      end
    end
  end
end
