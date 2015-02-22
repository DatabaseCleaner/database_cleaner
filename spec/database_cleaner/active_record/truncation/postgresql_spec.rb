require 'spec_helper'
require 'active_record'
require 'support/active_record/postgresql_setup'
require 'database_cleaner/active_record/truncation'
require 'database_cleaner/active_record/truncation/shared_fast_truncation'

module ActiveRecord
  module ConnectionAdapters
    describe "schema_migrations table" do
      it "is not truncated" do
        active_record_pg_migrate
        DatabaseCleaner::ActiveRecord::Truncation.new.clean
        result = active_record_pg_connection.execute("select count(*) from schema_migrations;")
        result.values.first.should eq ["2"]
      end
    end

    describe do
      before(:all) { active_record_pg_setup }

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
          User.count.should eq 0
        end

        it "truncates the table without id sequence" do
          2.times { Agent.create }

          connection.truncate_table('agents')
          Agent.count.should eq 0
        end

        it "resets AUTO_INCREMENT index of table" do
          2.times { User.create }
          User.delete_all

          connection.truncate_table('users')

          User.create.id.should eq 1
        end
      end

      describe ":except option cleanup" do
        it "should not truncate the tables specified in the :except option" do
          2.times { User.create }

          ::DatabaseCleaner::ActiveRecord::Truncation.new(:except => ['users']).clean
          expect( User.count ).to eq 2
        end
      end

      describe '#database_cleaner_table_cache' do
        it 'should default to the list of tables with their schema' do
          connection.database_cleaner_table_cache.first.should match(/^public\./)
        end
      end

      it_behaves_like "an adapter with pre-count truncation" do
        let(:connection) { active_record_pg_connection }
      end

    end
  end
end
