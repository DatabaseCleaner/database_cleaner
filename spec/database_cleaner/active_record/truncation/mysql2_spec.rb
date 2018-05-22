require 'support/active_record_helper'
require 'database_cleaner/active_record/truncation'
require 'database_cleaner/active_record/truncation/shared_fast_truncation'

RSpec.describe DatabaseCleaner::ActiveRecord::Truncation do
  let(:helper) { ActiveRecordHelper.new(:mysql2) }

  let(:connection) { helper.connection }

  around do |example|
    helper.setup
    example.run
    helper.teardown
  end

  describe "AR connection adapter monkeypatches" do
    describe "#truncate_table" do
      it "should truncate the table" do
        2.times { User.create }

        connection.truncate_table('users')

        expect(User.count).to eq 0
      end

      it "should reset AUTO_INCREMENT index of table" do
        2.times { User.create }
        User.delete_all

        connection.truncate_table('users')

        expect(User.create.id).to eq 1
      end
    end

    it_behaves_like "an adapter with pre-count truncation"
  end
end

