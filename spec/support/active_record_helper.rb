require 'active_record'
require 'database_cleaner/spec/database_helper'

class ActiveRecordHelper < DatabaseCleaner::Spec::DatabaseHelper
  def setup
    patch_mysql_adapters

    Kernel.const_set "User", Class.new(ActiveRecord::Base)
    Kernel.const_set "Agent", Class.new(ActiveRecord::Base)

    super

    connection.execute "CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(255));"
    connection.execute "INSERT INTO schema_migrations VALUES (1), (2);"
  end

  def teardown
    connection.execute "DROP TABLE schema_migrations;"

    super

    Kernel.send :remove_const, "User" if defined?(User)
    Kernel.send :remove_const, "Agent" if defined?(Agent)
  end

  private

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
    @connection = ActiveRecord::Base.connection
  end

  def patch_mysql_adapters
    # remove DEFAULT NULL from column definition, which is an error on primary keys in MySQL 5.7.3+
    primary_key_sql = "int(11) auto_increment PRIMARY KEY"
    ActiveRecord::ConnectionAdapters::MysqlAdapter::NATIVE_DATABASE_TYPES[:primary_key] = primary_key_sql
    ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = primary_key_sql
  end
end
