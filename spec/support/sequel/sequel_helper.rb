require 'sequel'
require 'support/database_helper'

def db_config
  SequelHelper.new.send(:db_config)
end

class SequelHelper < DatabaseHelper
  def setup
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

  def teardown
    if config[:url] == "postgres:///" || config[:url] == "sqlite:///"
      ::Sequel.connect(config[:url], config[:connection_options]) do |db|
        db.execute "DROP TABLE IF EXISTS precious_stones"
        db.execute "DROP TABLE IF EXISTS replaceable_trifles"
        db.execute "DROP TABLE IF EXISTS worthless_junk"
      end
    else
      ::Sequel.connect(config[:url], config[:connection_options].merge('database' => nil)) do |db|
        db.execute "DROP DATABASE IF EXISTS #{database}"
      end
    end
  rescue SQLite3::BusyException
  end

  private

  def database
    config[:connection_options]['database']
  end
end
