require 'yaml'

class DatabaseHelper < Struct.new(:config)
  # require 'logger'
  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def setup
    create_db
    establish_connection
    load_schema
  end

  def connection
    raise NotImplementedError
  end

  def teardown
    drop_db
  end

  private

  def establish_connection(config = default_config)
    raise NotImplementedError
  end

  def create_db
    establish_connection default_config.merge("database" => nil)
    connection.execute "CREATE DATABASE IF NOT EXISTS #{default_config['database']}"
  end

  def load_schema
    connection.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name INTEGER
      );
    SQL

    connection.execute <<-SQL
      CREATE TABLE IF NOT EXISTS agents (
        name INTEGER
      );
    SQL
  end

  def drop_db
    connection.execute "DROP DATABASE IF EXISTS #{default_config['database']}"
  end

  def db_config
    config_path = 'db/config.yml'
    @db_config ||= YAML.load(IO.read(config_path))
  end

  def default_config
    raise NotImplementedError
  end
end

