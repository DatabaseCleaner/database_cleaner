require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module PostgreSQLHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, pg"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def default_config
    db_config['postgres']
  end

  def create_db
    @encoding = default_config['encoding'] || ENV['CHARSET'] || 'utf8'
    begin
      establish_connection(default_config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
      ActiveRecord::Base.connection.drop_database(default_config['database']) rescue nil
      ActiveRecord::Base.connection.create_database(default_config['database'], default_config.merge('encoding' => @encoding))
    rescue Exception => e
      $stderr.puts e, *(e.backtrace)
      $stderr.puts "Couldn't create database for #{default_config.inspect}"
    end
  end

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end

  def active_record_pg_setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def active_record_pg_migrate
    create_db
    establish_connection
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'
  end

  def active_record_pg_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include PostgreSQLHelper
end
