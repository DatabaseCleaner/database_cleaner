require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

class MySQL2Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def active_record_mysql2_setup
    patch_mysql2_adapter
    create_db
    establish_connection
    active_record_load_schema
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end

  def active_record_mysql2_teardown
    ActiveRecord::Base.connection.drop_database default_config['database']
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

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection config
  end

  def patch_mysql2_adapter
    # remove DEFAULT NULL from column definition, which is an error on primary keys in MySQL 5.7.3+
    ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end

