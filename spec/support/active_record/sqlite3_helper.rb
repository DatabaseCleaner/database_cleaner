require 'support/active_record/base_helper'

class SQLite3Helper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

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
end

