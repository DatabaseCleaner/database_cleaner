require 'support/active_record/base_helper'

class MySQL2Helper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  def setup
    patch_mysql2_adapter
    super
  end

  private

  def default_config
    db_config['mysql2']
  end

  def create_db
    establish_connection(default_config.merge("database" => nil))

    ActiveRecord::Base.connection.drop_database default_config['database'] rescue nil
    ActiveRecord::Base.connection.create_database default_config['database']
  end

  def patch_mysql2_adapter
    # remove DEFAULT NULL from column definition, which is an error on primary keys in MySQL 5.7.3+
    ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end

