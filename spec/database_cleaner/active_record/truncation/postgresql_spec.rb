require 'support/active_record/postgresql_helper'
require 'database_cleaner/active_record/truncation'
require 'database_cleaner/active_record/truncation/shared_fast_truncation'

RSpec.describe DatabaseCleaner::ActiveRecord::Truncation do
  let(:helper) { PostgreSQLHelper.new }

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

      it "truncates the table without id sequence" do
        2.times { Agent.create }

        connection.truncate_table('agents')

        expect(Agent.count).to eq 0
      end

      it "resets AUTO_INCREMENT index of table" do
        2.times { User.create }
        User.delete_all

        connection.truncate_table('users')

        expect(User.create.id).to eq 1
      end
    end
  end

  describe ":except option cleanup" do
    it "should not truncate the tables specified in the :except option" do
      2.times { User.create }

      described_class.new(except: ['users']).clean

      expect( User.count ).to eq 2
    end
  end

  describe '#database_cleaner_table_cache' do
    it 'should default to the list of tables with their schema' do
      expect(connection.database_cleaner_table_cache.first).to match(/^public\./)
    end
  end

  it_behaves_like "an adapter with pre-count truncation"

  describe "schema_migrations table" do
    it "is not truncated" do

      subject.clean

      result = connection.execute("select count(*) from schema_migrations;")
      expect(result.values.first).to eq ["2"]
    end
  end
end

