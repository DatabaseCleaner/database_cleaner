require File.dirname(__FILE__) + '/../../spec_helper'
require 'active_record'
require 'database_cleaner/active_record/drop'


module ActiveRecord
  module ConnectionAdapters
    [MysqlAdapter, Mysql2Adapter, SQLite3Adapter, JdbcAdapter, PostgreSQLAdapter, IBM_DBAdapter].each do |adapter|
      describe adapter, "#drop_table" do
        it "responds" do
          adapter.new("foo").should respond_to(:drop_table)
        end
        it "should drop the table"
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    describe Drop do
      let(:connection) { mock('connection') }


      before(:each) do
        connection.stub!(:disable_referential_integrity).and_yield
        connection.stub!(:views).and_return([])
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      it "should drop all tables except for schema_migrations" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:drop_table).with('widgets')
        connection.should_receive(:drop_table).with('dogs')
        connection.should_not_receive(:drop_table).with('schema_migrations')

        Drop.new.drop
      end

      it "should only drop the tables specified in the :only option when provided" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:drop_table).with('widgets')
        connection.should_not_receive(:drop_table).with('dogs')

        Drop.new(:only => ['widgets']).drop
      end

      it "should not drop the tables specified in the :except option" do
        connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

        connection.should_receive(:drop_table).with('dogs')
        connection.should_not_receive(:drop_table).with('widgets')

        Drop.new(:except => ['widgets']).drop
      end

      it "should raise an error when :only and :except options are used" do
        running {
          Drop.new(:except => ['widgets'], :only => ['widgets'])
        }.should raise_error(ArgumentError)
      end

      it "should raise an error when invalid options are provided" do
        running { Drop.new(:foo => 'bar') }.should raise_error(ArgumentError)
      end

      it "should not drop views" do
        connection.stub!(:tables).and_return(%w[widgets dogs])
        connection.stub!(:views).and_return(["widgets"])

        connection.should_receive(:drop_table).with('dogs')
        connection.should_not_receive(:drop_table).with('widgets')

        Drop.new.drop
      end
    end
  end
end

