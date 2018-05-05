require 'support/active_record/base_helper'

class PostgreSQLHelper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  private

  def default_config
    db_config['postgres']
  end

  def create_db
    establish_connection default_config.merge('database' => 'postgres', 'schema_search_path' => 'public')
    connection.execute "CREATE DATABASE #{default_config['database']}"
  rescue ActiveRecord::StatementInvalid
  end
end

