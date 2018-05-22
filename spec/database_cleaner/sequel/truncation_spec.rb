require 'database_cleaner/sequel/truncation'
require 'database_cleaner/shared_strategy'
require 'support/sequel/sequel_helper'

module DatabaseCleaner
  module Sequel
    RSpec.describe Truncation do
      it_should_behave_like "a generic strategy"
      it_should_behave_like "a generic truncation strategy"

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
              it 'truncates all the tables' do
                subject.clean

                expect(db[:users]).to be_empty
                expect(db[:agents]).to be_empty
              end
            end

            context 'restricted to "only: [...]" some tables' do
              subject { described_class.new(only: ['users']) }

              it 'truncates only the mentioned tables (and leaves the rest alone)' do
                subject.clean

                expect(db[:users]).to be_empty
                expect(db[:agents].count).to eq(1)
              end
            end

            context 'restricted to "except: [...]" some tables' do
              subject { described_class.new(except: ['users']) } # XXX: Strings only, symbols are ignored

              it 'leaves the mentioned tables alone (and truncates the rest)' do
                subject.clean

                expect(db[:users].count).to eq(1)
                expect(db[:agents]).to be_empty
              end
            end
          end

          describe 'auto increment sequences' do
            it "resets AUTO_INCREMENT primary key seqeunce" do
              table = db[:users]
              2.times { table.insert }

              subject.clean

              id_after_clean = table.insert
              expect(id_after_clean).to eq 1
            end
          end

          describe "with pre_count optimization option" do
            subject { described_class.new(pre_count: true) }

            before { db[:users].insert }

            it "only truncates non-empty tables" do
              sql = case config[:url]
              when 'sqlite:///' then ["DELETE FROM `users`", anything]
              when 'postgres:///' then ['TRUNCATE TABLE "users" RESTART IDENTITY;', anything]
              else ["TRUNCATE TABLE `users`", anything]
              end
              expect(subject.db).to receive(:execute_ddl).once.with(*sql)
              subject.clean
            end
          end
        end
      end
    end
  end
end
