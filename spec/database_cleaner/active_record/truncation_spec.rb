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
          Truncation.new.clean
        end

        it "should use ActiveRecord's SchemaMigration.table_name" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[pre_schema_migrations_suf widgets dogs])
          allow(::ActiveRecord::Base).to receive(:table_name_prefix).and_return('pre_')
          allow(::ActiveRecord::Base).to receive(:table_name_suffix).and_return('_suf')

          expect(connection).to receive(:truncate_tables).with(['widgets', 'dogs'])

          Truncation.new.clean
        end

        it "should only truncate the tables specified in the :only option when provided" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          expect(connection).to receive(:truncate_tables).with(['widgets'])

          Truncation.new(:only => ['widgets']).clean
        end

        it "should not truncate the tables specified in the :except option" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          expect(connection).to receive(:truncate_tables).with(['dogs'])

          Truncation.new(:except => ['widgets']).clean
        end

        it "should raise an error when :only and :except options are used" do
          expect {
            Truncation.new(:except => ['widgets'], :only => ['widgets'])
          }.to raise_error(ArgumentError)
        end

        it "should raise an error when invalid options are provided" do
          expect { Truncation.new(:foo => 'bar') }.to raise_error(ArgumentError)
        end

        it "should not truncate views" do
          allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
          allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

          expect(connection).to receive(:truncate_tables).with(['dogs'])

          Truncation.new.clean
        end

        describe "relying on #pre_count_truncate_tables if connection allows it" do
          subject { Truncation.new }

          it "should rely on #pre_count_truncate_tables if #pre_count? returns true" do
            allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@pre_count", true)

            expect(connection).not_to receive(:truncate_tables).with(['dogs'])
            expect(connection).to receive(:pre_count_truncate_tables).with(['dogs'], :reset_ids => true)

            subject.clean
          end

          it "should not rely on #pre_count_truncate_tables if #pre_count? return false" do
            allow(connection).to receive(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            allow(connection).to receive(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@pre_count", false)

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
            Truncation.new({ :cache_tables => true }).clean
          end
        end

        context 'when :cache_tables is set to false' do
          it 'does not cache the list of tables to be truncated' do
            expect(connection).not_to receive(:database_cleaner_table_cache)
            expect(connection).to receive(:tables).and_return([])

            allow(connection).to receive(:truncate_tables)
            Truncation.new({ :cache_tables => false }).clean
          end
        end
      end

      describe '#pre_count?' do
        before(:each) do
          allow(connection).to receive(:disable_referential_integrity).and_yield
          allow(connection).to receive(:database_cleaner_view_cache).and_return([])
          allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
        end

        subject { Truncation.new }

        it 'should return false initially' do
          expect(subject.send(:pre_count?)).to eq false
        end

        it 'should return true if @reset_id is set and non false or nil' do
          subject.instance_variable_set(:"@pre_count", true)
          expect(subject.send(:pre_count?)).to eq true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@pre_count", false)
          expect(subject.send(:pre_count?)).to eq false
        end
      end

      describe '#reset_ids?' do
        before(:each) do
          allow(connection).to receive(:disable_referential_integrity).and_yield
          allow(connection).to receive(:database_cleaner_view_cache).and_return([])
          allow(::ActiveRecord::Base).to receive(:connection).and_return(connection)
        end

        subject { Truncation.new }

        it 'should return true initially' do
          expect(subject.send(:reset_ids?)).to eq true
        end

        it 'should return true if @reset_id is set and non falsey' do
          subject.instance_variable_set(:"@reset_ids", 'Something')
          expect(subject.send(:reset_ids?)).to eq true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@reset_ids", false)
          expect(subject.send(:reset_ids?)).to eq false
        end
      end
    end
  end
end
