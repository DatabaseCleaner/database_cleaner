require 'support/data_mapper/sqlite3_helper'
require 'database_cleaner/data_mapper/truncation'

RSpec.describe DatabaseCleaner::DataMapper::Truncation do
  let(:helper) { DataMapperSQLite3Helper.new }

  let(:connection) { helper.connection }

  around do |example|
    helper.setup
    example.run
    helper.teardown
  end

  describe "DM connection adapter monkeypatches" do
    before do
      2.times { DmUser.create }
    end

    describe "#truncate_table" do
      it "truncates the table" do
        connection.truncate_table(DmUser.storage_names[:default])
        expect(DmUser.count).to eq 0
      end

      it "resets AUTO_INCREMENT index of table" do
        connection.truncate_table(DmUser.storage_names[:default])
        expect(DmUser.create.id).to eq 1
      end
    end
  end
end
