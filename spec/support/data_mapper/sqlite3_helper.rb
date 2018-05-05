require 'dm-core'
require 'dm-sqlite-adapter'
require 'support/database_helper'

class ::DmUser
  include DataMapper::Resource

  self.storage_names[:default] = 'users'

  property :id, Serial
  property :name, String
end

class DataMapperSQLite3Helper < DatabaseHelper
  puts "DataMapper #{DataMapper::VERSION}, sqlite3"

  def connection
    DataMapper.repository.adapter
  end

  private

  def default_config
    db_config['sqlite3']
  end

  def create_db
    # NO-OP
  end

  def establish_connection(config = default_config)
    DataMapper.setup(:default, config)
  end
end

