require 'dm-core'
require 'dm-sqlite-adapter'
require 'support/database_helper'

class DataMapperSQLite3Helper < DatabaseHelper
  puts "DataMapper #{DataMapper::VERSION}, sqlite3"

  def setup
    Kernel.const_set "User", Class.new
    User.instance_eval do
      include DataMapper::Resource

      storage_names[:default] = 'users'

      property :id, User::Serial
      property :name, String
    end

    super
  end

  def teardown
    Kernel.send :remove_const, "User" if defined?(User)
  end

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

