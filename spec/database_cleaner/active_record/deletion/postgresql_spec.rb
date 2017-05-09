require 'spec_helper'
require 'active_record'
require 'support/active_record/postgresql_setup'
require 'database_cleaner/active_record/deletion'

module ActiveRecord
  module ConnectionAdapters
    describe "schema_migrations table" do
      it "is not deleted" do
        active_record_pg_migrate
        DatabaseCleaner::ActiveRecord::Deletion.new.clean
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

        it "deletes the table without id sequence" do
          2.times { Agent.create }

          connection.delete_table('agents')
          Agent.count.should eq 0
        end
      end

      describe ":except option cleanup" do
        it "should not delete the tables specified in the :except option" do
          2.times { User.create }

          ::DatabaseCleaner::ActiveRecord::Deletion.new(:except => ['users']).clean
          expect( User.count ).to eq 2
        end
      end

      describe '#database_cleaner_table_cache' do
        it 'should default to the list of tables with their schema' do
          connection.database_cleaner_table_cache.first.should match(/^public\./)
        end
      end
    end
  end
end
