require 'database_cleaner/sequel/deletion'
require 'database_cleaner/shared_strategy'
require 'support/sequel/sequel_helper'

module DatabaseCleaner
  module Sequel
    RSpec.describe Deletion do
      it_should_behave_like "a generic strategy"

      [
        { url: 'mysql:///',    connection_options: db_config['mysql'] },
        { url: 'mysql2:///',   connection_options: db_config['mysql2'] },
        { url: 'sqlite:///',   connection_options: db_config['sqlite3'] },
        { url: 'postgres:///', connection_options: db_config['postgres'] },
      ].each do |config|
        context "using a #{config[:url]} connection" do
          let(:helper) { SequelHelper.new(config) }

          around do |example|
            helper.setup
            example.run
            helper.teardown
          end

          let(:db) { helper.connection }

          before { subject.db = db }

          context 'when several tables have data' do
            before do
              db[:users].insert
              db[:agents].insert
            end

            context 'by default' do
              it 'deletes all the tables' do
                subject.clean

                expect(db[:users]).to be_empty
                expect(db[:agents]).to be_empty
              end
            end
          end
        end
      end
    end
  end
end
