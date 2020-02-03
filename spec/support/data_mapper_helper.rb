require 'dm-core'
require 'dm-sqlite-adapter'
require 'database_cleaner/spec/database_helper'

class DataMapperHelper < DatabaseCleaner::Spec::DatabaseHelper
  def setup
    super

    Kernel.const_set "User", Class.new
    User.instance_eval do
      include DataMapper::Resource

      storage_names[:default] = 'users'

      property :id, User::Serial
      property :name, String
    end
  end

  def teardown
    Kernel.send :remove_const, "User" if defined?(User)

    super
  end

  def connection
    DataMapper.repository.adapter
  end

  private

  def establish_connection(config = default_config)
    DataMapper.setup(:default, config)
  end
end
