require 'active_record'
require 'support/active_record/sqlite3_setup'
require 'database_cleaner/active_record/truncation'

describe DatabaseCleaner::ActiveRecord::Truncation do
  let(:helper) { SQLite3Helper.new }

  let(:connection) do
    helper.active_record_sqlite3_connection
  end

  around do |example|
    helper.active_record_sqlite3_setup

    example.run

    helper.active_record_sqlite3_teardown
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

