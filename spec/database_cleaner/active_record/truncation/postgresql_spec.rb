require 'spec_helper'
require 'active_record'
require 'support/active_record/postgresql_setup'
require 'database_cleaner/active_record/truncation'

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

      describe "#fast_truncate_tables" do
        
        context "with :reset_ids set true" do
          it "truncates the table" do
            2.times { User.create }

            connection.fast_truncate_tables(%w[users], :reset_ids => true)
            User.count.should be_zero
          end

          it "resets AUTO_INCREMENT index of table" do
            2.times { User.create }
            User.delete_all

            connection.fast_truncate_tables(%w[users]) # true is also the default
            User.create.id.should == 1
          end
        end

        
        context "with :reset_ids set false" do
          it "truncates the table" do
            2.times { User.create }

            connection.fast_truncate_tables(%w[users], :reset_ids => false)
            User.count.should be_zero
          end

          it "does not reset AUTO_INCREMENT index of table" do
            2.times { User.create }
            User.delete_all

            connection.fast_truncate_tables(%w[users], :reset_ids => false)

            User.create.id.should == 3
          end
        end
        
      end
    end
  end
end

