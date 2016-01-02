require File.dirname(__FILE__) + '/../../spec_helper'
require 'active_record'
require 'active_record/connection_adapters/mysql_adapter'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/postgresql_adapter'

require 'database_cleaner/active_record/deletion'

describe DatabaseCleaner::ActiveRecord::Deletion do
  let(:connection) { double('connection') }

  before(:each) do
    connection.stub(:disable_referential_integrity).and_yield
    connection.stub(:database_cleaner_view_cache).and_return([])
    ::ActiveRecord::Base.stub(:connection).and_return(connection)
  end

  describe '#clean' do
    it "deletes all tables that need cleaning" do
      connection.should_receive(:delete_table).with('widgets').once
      connection.should_receive(:delete_table).with('dogs').once

      strategy = DatabaseCleaner::ActiveRecord::Deletion.new
      strategy.stub(:tables_to_truncate).and_return(%w[widgets dogs])
      strategy.clean
    end

    it "only cleans tables in rows if information_schema exists" do
      connection.stub(:database_cleaner_table_cache).and_return(['schema_migrations', 'widgets', 'dogs'])
      connection.stub(:execute).with("SELECT 1 FROM information_schema.tables")
      connection.stub(:instance_variable_get).with('@config').and_return(database: 'DATABASE')
      connection.stub_chain(:pool, :spec, :config).and_return(database: 'DATABASE')
      connection.stub(:exec_query).with("SELECT table_name FROM information_schema.tables WHERE table_schema = 'DATABASE' AND table_rows > 0").
        and_return([{'table_name' => 'widgets'}, {'table_name' => 'schema_migrations'}])
      strategy = DatabaseCleaner::ActiveRecord::Deletion.new
      strategy.send(:tables_to_truncate, connection).should == ['widgets']
    end
  end
end
