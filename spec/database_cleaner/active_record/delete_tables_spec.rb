# Spec that test the new clean_tables feature
require File.dirname(__FILE__) + '/../../spec_helper'
require 'active_record'
require 'database_cleaner/active_record/deletion'

module ActiveRecord
  module ConnectionAdapters
    [MysqlAdapter, Mysql2Adapter, SQLite3Adapter, JdbcAdapter, PostgreSQLAdapter].each do |adapter|
      describe adapter, "#delete_table" do
        it "responds" do
          adapter.new("foo").should respond_to(:delete_table)
        end
        it "should delete the table"
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    describe Deletion do
      let(:connection) { mock('connection') }

      before(:each) do
        connection.stub!(:disable_referential_integrity).and_yield
        connection.stub!(:views).and_return([])
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      it "should delete all tables except for schema_migrations" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:delete_table).with('widgets')
        connection.should_receive(:delete_table).with('dogs')
        connection.should_not_receive(:delete_table).with('schema_migrations')

        Deletion.new.clean
      end

      it "should only clean the tables specified in the :only option when provided" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:delete_table).with('widgets')
        connection.should_not_receive(:delete_table).with('dogs')

        Deletion.new(:only => ['widgets']).clean
      end

      it "should not clean the tables specified in the :except option" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:delete_table).with('dogs')
        connection.should_not_receive(:delete_table).with('widgets')

        Deletion.new(:except => ['widgets']).clean
      end

      it "should raise an error when :only and :except options are used" do
        running {
          Deletion.new(:except => ['widgets'], :only => ['widgets'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when invalid options are provided" do
        running { Deletion.new(:foo => 'bar') }.should raise_error(ArgumentError)
      end

      it "should not clean views" do
        connection.stub!(:tables).and_return(%w[widgets dogs])
        connection.stub!(:views).and_return(["widgets"])

        connection.should_receive(:delete_table).with('dogs')
        connection.should_not_receive(:delete_table).with('widgets')

        Deletion.new.clean
      end
    end
  end
end


