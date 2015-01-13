require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module SQLite3Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def default_config
    db_config['sqlite3']
  end

  def create_db
    @encoding = default_config['encoding'] || ENV['CHARSET'] || 'utf8'
    begin
      establish_connection(default_config.merge('database' => 'sqlite3', 'schema_search_path' => 'public'))
    rescue Exception => e
      $stderr.puts e, *(e.backtrace)
      $stderr.puts "Couldn't create database for #{default_config.inspect}"
    end
  end

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end

  def active_record_sqlite3_setup
    create_db
    establish_connection
    active_record_load_schema
  end

  def active_record_sqlite3_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include SQLite3Helper
end
