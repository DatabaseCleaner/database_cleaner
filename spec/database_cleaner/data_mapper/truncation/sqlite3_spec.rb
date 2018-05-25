require 'support/data_mapper_helper'
require 'database_cleaner/data_mapper/truncation'

RSpec.describe DatabaseCleaner::DataMapper::Truncation do
  let(:helper) { DataMapperHelper.new(:sqlite3) }

  let(:connection) { helper.connection }

  around do |example|
    helper.setup
    example.run
    helper.teardown
  end

  describe "DM connection adapter monkeypatches" do
    before { 2.times { User.create } }

    describe "#truncate_table" do
      it "truncates the table and resets AUTO_INCREMENT index of table" do
        connection.truncate_table(User.storage_names[:default])
        expect(User.count).to eq 0
        expect(User.create.id).to eq 1
      end
    end
  end
end
