require File.dirname(__FILE__) + '/../../spec_helper'
require 'active_record'

require 'database_cleaner/active_record/truncation'

module ActiveRecord
  module ConnectionAdapters
    [MysqlAdapter, Mysql2Adapter, SQLite3Adapter, JdbcAdapter, PostgreSQLAdapter, IBM_DBAdapter].each do |adapter|
      describe adapter, "#truncate_table" do
        it "responds" do
          adapter.instance_methods.should include('truncate_table')
        end
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    describe Truncation do
      let(:connection) { mock('connection') }

      before(:each) do
        connection.stub!(:disable_referential_integrity).and_yield
        connection.stub!(:database_cleaner_view_cache).and_return([])
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      describe '#clean' do
        it "should truncate all tables except for schema_migrations" do
          connection.stub!(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_tables).with(['widgets', 'dogs'])
          Truncation.new.clean
        end

        it "should only truncate the tables specified in the :only option when provided" do
          connection.stub!(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_tables).with(['widgets'])

          Truncation.new(:only => ['widgets']).clean
        end

        it "should not truncate the tables specified in the :except option" do
          connection.stub!(:database_cleaner_table_cache).and_return(%w[schema_migrations widgets dogs])

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
          connection.stub!(:database_cleaner_table_cache).and_return(%w[widgets dogs])
          connection.stub!(:database_cleaner_view_cache).and_return(["widgets"])

          connection.should_receive(:truncate_tables).with(['dogs'])

          Truncation.new.clean
        end

        describe "relying on #fast_truncate_tables if connection allows it" do
          subject { Truncation.new }

          it "should rely on #fast_truncate_tables if #fast? returns true" do
            connection.stub!(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            connection.stub!(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@fast", true)

            connection.should_not_receive(:truncate_tables).with(['dogs'])
            connection.should_receive(:fast_truncate_tables).with(['dogs'], :reset_ids => true)

            subject.clean
          end

          it "should not rely on #fast_truncate_tables if #fast? return false" do
            connection.stub!(:database_cleaner_table_cache).and_return(%w[widgets dogs])
            connection.stub!(:database_cleaner_view_cache).and_return(["widgets"])

            subject.instance_variable_set(:"@fast", false)

            connection.should_not_receive(:fast_truncate_tables).with(['dogs'], :reset_ids => true)
            connection.should_receive(:truncate_tables).with(['dogs'])

            subject.clean
          end
        end
      end

      describe '#fast?' do
        before(:each) do
          connection.stub!(:disable_referential_integrity).and_yield
          connection.stub!(:database_cleaner_view_cache).and_return([])
          ::ActiveRecord::Base.stub!(:connection).and_return(connection)
        end

        subject { Truncation.new }
        its(:fast?) { should == false }

        it 'should return true if @reset_id is set and non false or nil' do
          subject.instance_variable_set(:"@fast", true)
          subject.send(:fast?).should == true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@fast", false)
          subject.send(:fast?).should == false
        end
      end
      
      describe '#reset_ids?' do
        before(:each) do
          connection.stub!(:disable_referential_integrity).and_yield
          connection.stub!(:database_cleaner_view_cache).and_return([])
          ::ActiveRecord::Base.stub!(:connection).and_return(connection)
        end
        
        subject { Truncation.new }
        its(:reset_ids?) { should == true }

        it 'should return true if @reset_id is set and non false or nil' do
          subject.instance_variable_set(:"@reset_ids", 'Something')
          subject.send(:reset_ids?).should == true
        end

        it 'should return false if @reset_id is set to false' do
          subject.instance_variable_set(:"@reset_ids", false)
          subject.send(:reset_ids?).should == false
        end
      end
    end
  end
end
