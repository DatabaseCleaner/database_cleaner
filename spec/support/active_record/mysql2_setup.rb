require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'


module MySQL2Helper
  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def default_config
    db_config['mysql2']
  end

  def create_db
    establish_connection(default_config.merge('database' => nil))

    ActiveRecord::Base.connection.drop_database default_config['database'] rescue nil
    ActiveRecord::Base.connection.create_database default_config['database']
  end

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection config
  end

  def active_record_mysql2_setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQL2Helper
end
