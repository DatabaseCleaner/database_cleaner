require 'spec_helper'
require 'dm-core'
require 'dm-sqlite-adapter'
require File.expand_path('../../../../support/data_mapper/sqlite3_setup', __FILE__)
require 'database_cleaner/data_mapper/truncation'

module DataMapper
  module ConnectionAdapters
    describe do
      before(:all) { data_mapper_sqlite3_setup }

      let(:adapter) { DataMapperSQLite3Adapter }

      let(:connection) do
        data_mapper_sqlite3_connection
      end

      before(:each) do
        connection.truncate_tables(DataMapper::Model.descendants.map { |d| d.storage_names[:default] || d.name.underscore })
      end

      describe "#truncate_table" do
        it "truncates the table" do
          2.times { DmUser.create }

          connection.truncate_table(DmUser.storage_names[:default])
          DmUser.count.should eq 0
        end

        it "resets AUTO_INCREMENT index of table" do
          2.times { DmUser.create }
          DmUser.destroy

          connection.truncate_table(DmUser.storage_names[:default])

          DmUser.create.id.should eq 1
        end
      end
    end
  end
end
