require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'


module MySQL2Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql2"

  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def config
    db_config['mysql2']
  end

  def create_db
    establish_connection(config.merge(:database => nil))

    ActiveRecord::Base.connection.drop_database config['database'] rescue nil
    ActiveRecord::Base.connection.create_database config['database']
  end

  def establish_connection config = config
    ActiveRecord::Base.establish_connection config
  end

  def active_record_mysql2_setup
    create_db
    establish_connection
    load_schema
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQL2Helper
end

