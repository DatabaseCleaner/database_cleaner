require File.dirname(__FILE__) + '/../../spec_helper'
require 'database_cleaner/active_record/truncation'
require 'active_record'
module ActiveRecord
  module ConnectionAdapters
    [MysqlAdapter, SQLite3Adapter, JdbcAdapter, PostgreSQLAdapter].each do |adapter|
      describe adapter, "#truncate_table" do
        it "should truncate the table"
      end
    end
  end
end

module DatabaseCleaner
  module ActiveRecord

    describe Truncation do
      let (:connection) { mock('connection') } 
      
      
      before(:each) do
        connection.stub!(:disable_referential_integrity).and_yield
        ::ActiveRecord::Base.stub!(:connection).and_return(connection)
      end

      context "single connection" do
        it "should truncate all tables except for schema_migrations" do
          connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_table).with('widgets')
          connection.should_receive(:truncate_table).with('dogs')
          connection.should_not_receive(:truncate_table).with('schema_migrations')

          Truncation.new.clean
        end

        it "should only truncate the tables specified in the :only option when provided" do
          connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_table).with('widgets')
          connection.should_not_receive(:truncate_table).with('dogs')

          Truncation.new(:only => ['widgets']).clean
        end

        it "should not truncate the tables specified in the :except option" do
          connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])

          connection.should_receive(:truncate_table).with('dogs')
          connection.should_not_receive(:truncate_table).with('widgets')

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
      end
      
      # context "multiple connection" do
      #    
      #    let (:another_connection) { mock('another connection') }
      #    let (:model_klass) { mock('klass') }
      #    
      #    before(:each) do
      #      another_connection.stub!(:disable_referential_integrity).and_yield
      #      model_klass.stub!(:connection).and_return(another_connection)
      #      
      #      DatabaseCleaner::ActiveRecord.connection_klasses = [model_klass]
      #    end
      # 
      #    after(:each) do
      #      DatabaseCleaner::ActiveRecord.connection_klasses = []
      #    end
      #    
      #    it "should truncate all tables except for schema_migrations on both connections" do
      #      connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      #      another_connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      # 
      #      connection.should_receive(:truncate_table).with('widgets')
      #      connection.should_receive(:truncate_table).with('dogs')
      #      connection.should_not_receive(:truncate_table).with('schema_migrations')
      #      
      #      another_connection.should_receive(:truncate_table).with('widgets')
      #      another_connection.should_receive(:truncate_table).with('dogs')
      #      another_connection.should_not_receive(:truncate_table).with('schema_migrations')
      #      
      #      Truncation.new.clean
      #    end
      # 
      #    it "should only truncate the tables specified in the :only option when provided" do
      #      connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      #      another_connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      # 
      #      connection.should_receive(:truncate_table).with('widgets')
      #      connection.should_not_receive(:truncate_table).with('dogs')
      #      
      #      another_connection.should_receive(:truncate_table).with('widgets')
      #      another_connection.should_not_receive(:truncate_table).with('dogs')
      # 
      #      Truncation.new(:only => ['widgets']).clean
      #    end
      # 
      #    it "should not truncate the tables specified in the :except option" do
      #      connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      #      another_connection.stub!(:tables).and_return(%w[schema_migrations widgets dogs])
      # 
      #      connection.should_receive(:truncate_table).with('dogs')
      #      connection.should_not_receive(:truncate_table).with('widgets')
      #      
      #      another_connection.should_receive(:truncate_table).with('dogs')
      #      another_connection.should_not_receive(:truncate_table).with('widgets')
      # 
      #      Truncation.new(:except => ['widgets']).clean
      #    end
      # 
      #    it "should raise an error when :only and :except options are used" do
      #      running {
      #        Truncation.new(:except => ['widgets'], :only => ['widgets'])
      #      }.should raise_error(ArgumentError)
      #    end
      # 
      #    it "should raise an error when invalid options are provided" do
      #      running { Truncation.new(:foo => 'bar') }.should raise_error(ArgumentError)
      #    end
      #  end
      
    end

  end
end
