require 'support/active_record/database_setup'
require 'support/active_record/schema_setup'

module SQLite3Helper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

  # ActiveRecord::Base.logger = Logger.new(STDERR)

  def config
    db_config['sqlite3']
  end

  def create_db
    @encoding = config['encoding'] || ENV['CHARSET'] || 'utf8'
    begin
      establish_connection(config.merge('database' => 'sqlite3', 'schema_search_path' => 'public'))
    rescue Exception => e
      $stderr.puts e, *(e.backtrace)
      $stderr.puts "Couldn't create database for #{config.inspect}"
    end
  end

  def establish_connection config = config
    ActiveRecord::Base.establish_connection(config)
  end

  def active_record_sqlite3_setup
    create_db
    establish_connection
    load_schema
  end

  def active_record_sqlite3_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include SQLite3Helper
end
