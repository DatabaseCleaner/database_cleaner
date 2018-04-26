require 'dm-core'
require 'dm-sqlite-adapter'
require 'support/data_mapper/sqlite3_setup'
require 'database_cleaner/data_mapper/truncation'

describe DatabaseCleaner::DataMapper::Truncation do
  let(:helper) { DataMapperSQLite3Helper.new }

  let(:connection) do
    helper.data_mapper_sqlite3_connection
  end

  around do |example|
    helper.data_mapper_sqlite3_setup

    example.run

    helper.data_mapper_sqlite3_teardown
  end

  describe "DM connection adapter monkeypatches" do
    describe "#truncate_table" do
      it "truncates the table" do
        2.times { DmUser.create }

        connection.truncate_table(DmUser.storage_names[:default])
        expect(DmUser.count).to eq 0
      end

      it "resets AUTO_INCREMENT index of table" do
        2.times { DmUser.create }
        DmUser.destroy

        connection.truncate_table(DmUser.storage_names[:default])

        expect(DmUser.create.id).to eq 1
      end
    end
  end
end
