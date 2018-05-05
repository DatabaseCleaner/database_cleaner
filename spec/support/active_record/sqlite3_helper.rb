require 'support/active_record/base_helper'

class SQLite3Helper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

  private

  def default_config
    db_config['sqlite3']
  end

  def establish_connection
    super default_config.merge('database' => 'sqlite3', 'schema_search_path' => 'public')
  end

  def create_db
    # NO-OP
  end
end

