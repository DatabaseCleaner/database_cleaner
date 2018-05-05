require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

class BaseHelper
  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def migrate
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'
  end

  def connection
    ActiveRecord::Base.connection
  end

  def teardown
    tables = %w(users agents)
    tables.each do |table|
      connection.execute "DROP TABLE IF EXISTS #{table}"
    end
  end

  private

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end

  def create_db
    establish_connection default_config.merge("database" => nil)
    connection.execute "CREATE DATABASE IF NOT EXISTS #{default_config['database']}"
  end
end

