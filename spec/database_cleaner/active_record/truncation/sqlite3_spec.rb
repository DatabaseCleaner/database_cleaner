require 'support/active_record/active_record_helper'
require 'database_cleaner/active_record/truncation'

RSpec.describe DatabaseCleaner::ActiveRecord::Truncation do
  let(:helper) { ActiveRecordHelper.new(nil, :sqlite3) }

  let(:connection) { helper.connection }

  around do |example|
    helper.setup
    example.run
    helper.teardown
  end

  describe "AR connection adapter monkeypatches" do
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

