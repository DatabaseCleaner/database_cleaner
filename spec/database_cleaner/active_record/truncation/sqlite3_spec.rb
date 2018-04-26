require 'spec_helper'
require 'active_record'
require 'support/active_record/sqlite3_setup'
require 'database_cleaner/active_record/truncation'

module ActiveRecord
  module ConnectionAdapters
    describe do
      before(:all) { SQLite3Helper.active_record_sqlite3_setup }

      let(:connection) do
        SQLite3Helper.active_record_sqlite3_connection
      end

      before(:each) do
        connection.truncate_tables connection.tables
      end

      describe "#truncate_table" do
        it "truncates the table" do
          2.times { User.create }

          connection.truncate_table('users')
          expect(User.count).to eq 0
        end

        it "resets AUTO_INCREMENT index of table" do
          2.times { User.create }
          User.delete_all

          connection.truncate_table('users')

          expect(User.create.id).to eq 1
        end
      end

    end
  end
end

