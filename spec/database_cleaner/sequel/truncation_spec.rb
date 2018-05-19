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
          around do |example|
            helper = SequelHelper.new(config)
            helper.setup

            example.run

            helper.teardown
          end

          let(:db) { ::Sequel.connect(config[:url], config[:connection_options]) }

          before { subject.db = db }

          context 'when several tables have data' do
            before do
              db.create_table!(:precious_stones) { primary_key :id }
              db.create_table!(:replaceable_trifles) { primary_key :id }
              db.create_table!(:worthless_junk) { primary_key :id }

              db[:precious_stones].insert
              db[:replaceable_trifles].insert
              db[:worthless_junk].insert
            end

            context 'by default' do
              it 'truncates all the tables' do
                subject.clean

                expect(db[:replaceable_trifles]).to be_empty
                expect(db[:worthless_junk]).to be_empty
                expect(db[:precious_stones]).to be_empty
              end
            end

            context 'restricted to "only: [...]" some tables' do
              subject { described_class.new(only: ['worthless_junk', 'replaceable_trifles']) }

              it 'truncates only the mentioned tables (and leaves the rest alone)' do
                subject.clean

                expect(db[:replaceable_trifles]).to be_empty
                expect(db[:worthless_junk]).to be_empty
                expect(db[:precious_stones].count).to eq(1)
              end
            end

            context 'restricted to "except: [...]" some tables' do
              subject { described_class.new(except: ['precious_stones']) } # XXX: Strings only, symbols are ignored

              it 'leaves the mentioned tables alone (and truncates the rest)' do
                subject.clean

                expect(db[:replaceable_trifles]).to be_empty
                expect(db[:worthless_junk]).to be_empty
                expect(db[:precious_stones].count).to eq(1)
              end
            end
          end

          describe 'auto increment sequences' do
            it "resets AUTO_INCREMENT primary key seqeunce" do
              db.create_table!(:replaceable_trifles) { primary_key :id }
              table = db[:replaceable_trifles]
              2.times { table.insert }

              subject.clean

              id_after_clean = table.insert
              expect(id_after_clean).to eq 1
            end
          end

          describe "with pre_count optimization option" do
            subject { described_class.new(pre_count: true) }

            before do
              db.create_table!(:precious_stones) { primary_key :id }
              db.create_table!(:replaceable_trifles) { primary_key :id }
              db[:precious_stones].insert
            end

            it "only truncates non-empty tables" do
              sql = case config[:url]
              when 'sqlite:///' then ["DELETE FROM `precious_stones`", anything]
              when 'postgres:///' then ['TRUNCATE TABLE "precious_stones" RESTART IDENTITY;', anything]
              else ["TRUNCATE TABLE `precious_stones`", anything]
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
