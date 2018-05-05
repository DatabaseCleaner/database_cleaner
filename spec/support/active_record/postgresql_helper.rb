require 'support/active_record/base_helper'

class PostgreSQLHelper < BaseHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  def teardown
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
end

