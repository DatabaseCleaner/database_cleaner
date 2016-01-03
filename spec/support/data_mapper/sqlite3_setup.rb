require 'support/connection_helpers'
require 'support/data_mapper/schema_setup'

module DataMapperSQLite3Helper

  puts "DataMapper #{DataMapper::VERSION}, sqlite3"

  def create_db
    ::ConnectionHelpers::DataMapper.build_connection
  end

  def data_mapper_sqlite3_setup
    create_db
    data_mapper_load_schema
  end

  def data_mapper_sqlite3_connection
    DataMapper.repository.adapter
  end
end

RSpec.configure do |c|
  c.include(DataMapperSQLite3Helper)
end
