require 'spec_helper'
require 'active_record'
require 'support/active_record/sqlite3_setup'
require 'database_cleaner/active_record/deletion'

module ActiveRecord
  module ConnectionAdapters
    describe do
      before(:all) { active_record_sqlite3_setup }

      let(:connection) do
        active_record_sqlite3_connection
      end

      before(:each) do
        connection.tables.each do |table|
          connection.delete_table table
        end
      end

      describe "#delete_table" do
        it "deletes the table" do
          2.times { User.create }

          connection.delete_table('users')
          User.count.should eq 0
        end
      end
    end
  end
end
