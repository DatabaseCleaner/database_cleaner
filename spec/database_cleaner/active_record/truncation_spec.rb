require File.dirname(__FILE__) + '/../../spec_helper'
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
      describe adapter, "#truncate_table" do
        it "responds" do
          adapter.instance_methods.should include(:truncate_table)
        end
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    describe Truncation do
      let(:connection) { double('connection') }

      before(:each) do
        connection.stub(:disable_referential_integrity).and_yield
        connection.stub(:database_cleaner_view_cache).and_return([])
        ::ActiveRecord::Base.stub(:connection).and_return(connection)
      end

      describe '#clean' do
        it "should truncate all tables except for schema_migrations" do
          connection.stub(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_tables).with(['widgets', 'dogs'])
          Truncation.new.clean
        end

        it "should use ActiveRecord's schema_migrations_table_name" do
          connection.stub(:database_cleaner_table_cache).and_return(%w[pre_schema_migrations_suf widgets dogs])
          ::ActiveRecord::Base.stub(:table_name_prefix).and_return('pre_')
          ::ActiveRecord::Base.stub(:table_name_suffix).and_return('_suf')

          connection.should_receive(:truncate_tables).with(['widgets', 'dogs'])

          Truncation.new.clean
        end

        it "should only truncate the tables specified in the :only option when provided" do
          connection.stub(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_tables).with(['widgets'])

          Truncation.new(:only => ['widgets']).clean
        end

        it "should not truncate the tables specified in the :except option" do
          connection.stub(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_tables).with(['dogs'])

          Truncation.new(:except => ['widgets']).clean
        end

        it "should raise an error when :only and :except options are used" do
          running {
            Truncation.new(:except => ['widgets'], :only => ['widgets'])
          }.should raise_error(ArgumentError)
        end

        it "should raise an error when invalid options are provided" do
          running { Truncation.new(:foo => 'bar') }.should raise_error(ArgumentError)
        end

        it "should not truncate views" do
          connection.stub(:database_cleaner_table_cache).and_return(%w[widgets dogs])
          connection.stub(:database_cleaner_view_cache).and_return(["widgets"])

          connection.should_receive(:truncate_tables).with(['dogs'])

          Truncation.new.clean
        end

        describe "relying on #pre_count_truncate_tables if connection allows it" do
          subject { Truncation.new }

          it "should rely on #pre_count_truncate_tables if #pre_count? returns true" do
            connection.stub(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            connection.stub(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@pre_count", true)

            connection.should_not_receive(:truncate_tables).with(['dogs'])
            connection.should_receive(:pre_count_truncate_tables).with(['dogs'], :reset_ids => true)

            subject.clean
          end

          it "should not rely on #pre_count_truncate_tables if #pre_count? return false" do
            connection.stub(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            connection.stub(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@pre_count", false)

            connection.should_not_receive(:pre_count_truncate_tables).with(['dogs'], :reset_ids => true)
            connection.should_receive(:truncate_tables).with(['dogs'])

            subject.clean
          end
        end

        context 'when :cache_tables is set to true' do
          it 'caches the list of tables to be truncated' do
            connection.should_receive(:database_cleaner_table_cache).and_return([])
            connection.should_not_receive(:tables)

            connection.stub(:truncate_tables)
            Truncation.new({ :cache_tables => true }).clean
          end
        end

        context 'when :cache_tables is set to false' do
          it 'does not cache the list of tables to be truncated' do
            connection.should_not_receive(:database_cleaner_table_cache)
            connection.should_receive(:tables).and_return([])

            connection.stub(:truncate_tables)
            Truncation.new({ :cache_tables => false }).clean
          end
        end
      end

      describe '#pre_count?' do
        before(:each) do
          connection.stub(:disable_referential_integrity).and_yield
          connection.stub(:database_cleaner_view_cache).and_return([])
          ::ActiveRecord::Base.stub(:connection).and_return(connection)
        end

        subject { Truncation.new }
        its(:pre_count?) { should eq false }

        it 'should return true if @reset_id is set and non false or nil' do
          subject.instance_variable_set(:"@pre_count", true)
          subject.send(:pre_count?).should eq true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@pre_count", false)
          subject.send(:pre_count?).should eq false
        end
      end

      describe '#reset_ids?' do
        before(:each) do
          connection.stub(:disable_referential_integrity).and_yield
          connection.stub(:database_cleaner_view_cache).and_return([])
          ::ActiveRecord::Base.stub(:connection).and_return(connection)
        end

        subject { Truncation.new }
        its(:reset_ids?) { should eq true }

        it 'should return true if @reset_id is set and non false or nil' do
          subject.instance_variable_set(:"@reset_ids", 'Something')
          subject.send(:reset_ids?).should eq true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@reset_ids", false)
          subject.send(:reset_ids?).should eq false
        end
      end
    end
  end
end
