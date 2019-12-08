require 'support/active_record_helper'
require 'database_cleaner/active_record/truncation'

RSpec.describe DatabaseCleaner::ActiveRecord::Truncation do
  ActiveRecordHelper.with_all_dbs do |helper|
    context "using a #{helper.db} connection" do
      around do |example|
        helper.setup
        example.run
        helper.teardown
      end

      let(:connection) { helper.connection }

      before do
        allow(connection).to receive(:disable_referential_integrity).and_yield
        allow(connection).to receive(:database_cleaner_view_cache).and_return([])
      end

      describe '#clean' do
        context "with records" do
          before do
            2.times { User.create! }
            2.times { Agent.create! }
          end

          it "should truncate all tables" do
            expect { subject.clean }
              .to change { [User.count, Agent.count] }
              .from([2,2])
              .to([0,0])
          end

          it "should reset AUTO_INCREMENT index of table" do
            subject.clean
            expect(User.create.id).to eq 1
          end

          xit "should not reset AUTO_INCREMENT index of table if :reset_ids is false" do
            described_class.new(reset_ids: false).clean
            expect(User.create.id).to eq 3
          end

          it "should truncate all tables except for schema_migrations" do
            subject.clean
            count = connection.select_value("select count(*) from schema_migrations;").to_i
            expect(count).to eq 2
          end

          it "should only truncate the tables specified in the :only option when provided" do
            expect { described_class.new(only: ['agents']).clean }
              .to change { [User.count, Agent.count] }
              .from([2,2])
              .to([2,0])
          end

          it "should not truncate the tables specified in the :except option" do
            expect { described_class.new(except: ['users']).clean }
              .to change { [User.count, Agent.count] }
              .from([2,2])
              .to([2,0])
          end

          it "should raise an error when :only and :except options are used" do
            expect {
              described_class.new(except: ['widgets'], only: ['widgets'])
            }.to raise_error(ArgumentError)
          end

          it "should raise an error when invalid options are provided" do
            expect { described_class.new(foo: 'bar') }.to raise_error(ArgumentError)
          end

          it "should not truncate views" do
            allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

            expect(connection).to receive(:truncate_tables).with('dogs')

            subject.clean
          end
        end

        describe "with pre_count optimization option" do
          subject { described_class.new(pre_count: true) }

          it "only truncates non-empty tables" do
            pending if helper.db == :sqlite3
            pending if helper.db == :postgres

            User.create!

            expect(connection).to receive(:truncate_tables).with('users')
            subject.clean
          end
        end

        context 'when :cache_tables is set to true' do
          it 'caches the list of tables to be truncated' do
            expect(connection).to receive(:database_cleaner_table_cache).and_return([])
            expect(connection).not_to receive(:tables)

            allow(connection).to receive(:truncate_tables)
            described_class.new(cache_tables: true).clean
          end
        end

        context 'when :cache_tables is set to false' do
          it 'does not cache the list of tables to be truncated' do
            expect(connection).not_to receive(:database_cleaner_table_cache)
            expect(connection).to receive(:tables).and_return([])

            allow(connection).to receive(:truncate_tables)
            described_class.new(cache_tables: false).clean
          end
        end

        context 'truncate tables with different arg inputs' do
          before do
            2.times { User.create! }
            2.times { Agent.create! }
          end

          it "should truncate given a list of tables" do
            expect { connection.truncate_tables(['users', 'agents']) }
              .to change { [User.count, Agent.count] }
              .from([2,2])
              .to([0,0])
          end

          it "should truncate given tables as args" do
            expect { connection.truncate_tables('users', 'agents') }
              .to change { [User.count, Agent.count] }
              .from([2,2])
              .to([0,0])
          end
        end
      end
    end
  end
end
