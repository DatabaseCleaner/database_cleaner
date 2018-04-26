require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

class PostgreSQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def active_record_pg_setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def active_record_pg_migrate
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'
  end

  def active_record_pg_connection
    ActiveRecord::Base.connection
  end

  def active_record_pg_teardown
    ActiveRecord::Base.connection.execute "DROP TABLE users, agents;"
  rescue ActiveRecord::StatementInvalid
  end

  private

  def default_config
    db_config['postgres']
  end

  def create_db
    @encoding = default_config['encoding'] || ENV['CHARSET'] || 'utf8'
    establish_connection(default_config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database(default_config['database'], default_config.merge('encoding' => @encoding))
  rescue ActiveRecord::StatementInvalid
  end

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end
end

