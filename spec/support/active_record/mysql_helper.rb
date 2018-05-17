require 'support/active_record/active_record_helper'

class MySQLHelper < ActiveRecordHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  def setup
    patch_mysql_adapter
    super
  end

  private

  def default_config
    db_config['mysql']
  end

  def patch_mysql_adapter
    # remove DEFAULT NULL from column definition, which is an error on primary keys in MySQL 5.7.3+
    ActiveRecord::ConnectionAdapters::MysqlAdapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end

