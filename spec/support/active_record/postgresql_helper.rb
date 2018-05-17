require 'support/active_record/active_record_helper'

class PostgreSQLHelper < ActiveRecordHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  private

  def default_config
    db_config['postgres']
  end

  def create_db
    establish_connection default_config.merge('database' => 'postgres')
    connection.execute "CREATE DATABASE #{default_config['database']}"
  rescue ActiveRecord::StatementInvalid
  end
end

