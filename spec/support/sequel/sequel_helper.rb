require 'sequel'
require 'support/database_helper'

def db_config
  SequelHelper.new.send(:db_config)
end

class SequelHelper < DatabaseHelper
  attr_reader :connection

  def teardown
    if config[:url] == "postgres:///" || config[:url] == "sqlite:///"
      ::Sequel.connect(config[:url], config[:connection_options]) do |db|
        db.execute "DROP TABLE IF EXISTS users"
        db.execute "DROP TABLE IF EXISTS agents"
      end
    else
      ::Sequel.connect(config[:url], config[:connection_options].merge('database' => nil)) do |db|
        db.execute "DROP DATABASE IF EXISTS #{database}"
      end
    end
  rescue SQLite3::BusyException
  end

  private

  def establish_connection
    @connection = ::Sequel.connect(config[:url], config[:connection_options])
  end

  def create_db
    if config[:url] == "sqlite:///"
      # NO-OP
    elsif config[:url] == "postgres:///"
      ::Sequel.connect(config[:url], config[:connection_options].merge('database' => 'postgres')) do |db|
        begin
          db.execute "CREATE DATABASE #{database}"
        rescue ::Sequel::DatabaseError
        end
      end
    else
      ::Sequel.connect(config[:url], config[:connection_options].merge('database' => nil)) do |db|
        db.execute "DROP DATABASE IF EXISTS #{database}"
        db.execute "CREATE DATABASE #{database}"
      end
    end
  end

  def load_schema
    connection.create_table!(:users) { primary_key :id }
    connection.create_table!(:agents) { primary_key :id }
  end

  def database
    config[:connection_options]['database']
  end
end
