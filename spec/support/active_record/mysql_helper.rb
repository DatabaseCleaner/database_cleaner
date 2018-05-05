require 'support/active_record/base_helper'

class MySQLHelper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  def setup
    patch_mysql_adapter
    super
  end

  private

  def default_config
    db_config['mysql']
  end

  def create_db
    ActiveRecord::Base.establish_connection default_config.merge("database" => nil)
    ActiveRecord::Base.connection.drop_database default_config['database'] rescue nil
    ActiveRecord::Base.connection.create_database default_config['database']
    ActiveRecord::Base.establish_connection default_config
  end

  def patch_mysql_adapter
    # remove DEFAULT NULL from column definition, which is an error on primary keys in MySQL 5.7.3+
    ActiveRecord::ConnectionAdapters::MysqlAdapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end

