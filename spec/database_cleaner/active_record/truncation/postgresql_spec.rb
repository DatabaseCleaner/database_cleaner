require 'spec_helper'
require 'active_record'
require 'support/active_record/postgresql_setup'
require 'database_cleaner/active_record/truncation'
require 'database_cleaner/active_record/truncation/shared_fast_truncation'

module ActiveRecord
  module ConnectionAdapters
    describe do
      before(:all) { active_record_pg_setup }

      let(:adapter) { PostgreSQLAdapter }

      let(:connection) do
        active_record_pg_connection
      end

      before(:each) do
        connection.truncate_tables connection.tables
      end

      describe "#truncate_table" do
        it "truncates the table" do
          2.times { User.create }

          connection.truncate_table('users')
          User.count.should == 0
        end

        it "resets AUTO_INCREMENT index of table" do
          2.times { User.create }
          User.delete_all

          connection.truncate_table('users')

          User.create.id.should == 1
        end
      end

      it_behaves_like "an adapter with pre-count truncation" do
        let(:adapter) { PostgreSQLAdapter }
        let(:connection) { active_record_pg_connection }
      end

    end
  end
end

