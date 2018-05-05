require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

class SQLite3Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def connection
    ActiveRecord::Base.connection
  end

  def teardown
    ActiveRecord::Base.connection.truncate_table('users')
    ActiveRecord::Base.connection.truncate_table('agents')
  end

  private

  def default_config
    db_config['sqlite3']
  end

  def create_db
    @encoding = default_config['encoding'] || ENV['CHARSET'] || 'utf8'
    establish_connection(default_config.merge('database' => 'sqlite3', 'schema_search_path' => 'public'))
  end

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end
end

