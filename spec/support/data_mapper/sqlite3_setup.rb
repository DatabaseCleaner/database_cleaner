require 'support/active_record/database_setup'
require 'support/data_mapper/schema_setup'

class DataMapperSQLite3Helper
  puts "DataMapper #{DataMapper::VERSION}, sqlite3"

  def data_mapper_sqlite3_setup
    create_db
    establish_connection
    data_mapper_load_schema
  end

  def data_mapper_sqlite3_connection
    DataMapper.repository.adapter
  end

  def data_mapper_sqlite3_teardown
    DataMapper.repository.adapter.truncate_tables(DataMapper::Model.descendants.map { |d| d.storage_names[:default] || d.name.underscore })
  end

  private

  def default_config
    db_config['sqlite3']
  end

  def create_db
    @encoding = default_config['encoding'] || ENV['CHARSET'] || 'utf8'
    establish_connection(default_config.merge('database' => 'sqlite3', 'schema_search_path' => 'public'))
  end

  def establish_connection(config = default_config)
    DataMapper.setup(:default, config)
  end
end

