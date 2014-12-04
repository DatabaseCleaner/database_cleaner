require 'spec_helper'
require 'active_record'
require 'support/active_record/sqlite3_setup'
require 'database_cleaner/active_record/truncation'

module ActiveRecord
  module ConnectionAdapters
    describe do
      before(:all) { active_record_sqlite3_setup }

      let(:connection) do
        active_record_sqlite3_connection
      end

      before(:each) do
        connection.truncate_tables connection.tables
      end

      describe "#truncate_table" do
        it "truncates the table" do
          2.times { User.create }

          connection.truncate_table('users')
          User.count.should eq 0
        end

        it "resets AUTO_INCREMENT index of table" do
          2.times { User.create }
          User.delete_all

          connection.truncate_table('users')

          User.create.id.should eq 1
        end
      end

    end
  end
end

