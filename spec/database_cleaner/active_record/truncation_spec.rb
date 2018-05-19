require 'active_record'
require 'active_record/connection_adapters/mysql_adapter'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/postgresql_adapter'

require 'database_cleaner/active_record/truncation'

module ActiveRecord
  module ConnectionAdapters
    #JdbcAdapter IBM_DBAdapter
    [ MysqlAdapter, Mysql2Adapter, SQLite3Adapter, PostgreSQLAdapter ].each do |adapter|
      RSpec.describe adapter, "#truncate_table" do
        it "responds" do
          expect(adapter.instance_methods).to include(:truncate_table)
        end
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    RSpec.describe Truncation do
      let(:connection) { double('connection') }

      before(:each) do
        allow(connection).to receive(:disable_referential_integrity).and_yield
        allow(connection).to receive(:database_cleaner_view_cache).and_return([])
        allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
      end

      describe '#clean' do
        it "should truncate all tables except for schema_migrations" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          expect(connection).to receive(:truncate_tables).with(['widgets', 'dogs'])
          subject.clean
        end

        it "should use ActiveRecord's SchemaMigration.table_name" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[pre_schema_migrations_suf widgets dogs])
          allow(::ActiveRecord::Base).to receive(:table_name_prefix).and_return('pre_')
          allow(::ActiveRecord::Base).to receive(:table_name_suffix).and_return('_suf')

          expect(connection).to receive(:truncate_tables).with(['widgets', 'dogs'])

          subject.clean
        end

        it "should only truncate the tables specified in the :only option when provided" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          expect(connection).to receive(:truncate_tables).with(['widgets'])

          described_class.new(only: ['widgets']).clean
        end

        it "should not truncate the tables specified in the :except option" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          expect(connection).to receive(:truncate_tables).with(['dogs'])

          described_class.new(except: ['widgets']).clean
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

          expect(connection).to receive(:truncate_tables).with(['dogs'])

          subject.clean
        end

        describe "relying on #pre_count_truncate_tables if connection allows it" do
          it "should rely on #pre_count_truncate_tables if pre_count is set" do
            allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

            subject = described_class.new(pre_count: true)

            expect(connection).not_to receive(:truncate_tables).with(['dogs'])
            expect(connection).to receive(:pre_count_truncate_tables).with(['dogs'], :reset_ids => true)

            subject.clean
          end

          it "should not rely on #pre_count_truncate_tables if pre_count is not set" do
            allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

            expect(connection).not_to receive(:pre_count_truncate_tables).with(['dogs'], :reset_ids => true)
            expect(connection).to receive(:truncate_tables).with(['dogs'])

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
      end
    end
  end
end
