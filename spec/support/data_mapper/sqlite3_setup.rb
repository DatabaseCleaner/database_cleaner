require 'support/active_record/database_setup'
require 'support/data_mapper/schema_setup'

module DataMapperSQLite3Helper

  puts "DataMapper #{DataMapper::VERSION}, sqlite3"

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

  def establish_connection(config = config)
    DataMapper.setup(:default, config)
  end

  def data_mapper_sqlite3_setup
    create_db
    establish_connection
    data_mapper_load_schema
  end

  def data_mapper_sqlite3_connection
    DataMapper.repository.adapter
  end
end

RSpec.configure do |c|
  c.include(DataMapperSQLite3Helper)
end
