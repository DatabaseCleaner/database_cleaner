require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module MySQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, mysql"

  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def config
    db_config['mysql']
  end

  def create_db
    establish_connection(config.merge(:database => nil))

    ActiveRecord::Base.connection.drop_database config['database'] rescue nil
    ActiveRecord::Base.connection.create_database config['database']
  end

  def establish_connection config = config
    ActiveRecord::Base.establish_connection config
  end

  def active_record_mysql_setup
    create_db
    establish_connection
    load_schema
  end

  def active_record_mysql_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQLHelper
end
