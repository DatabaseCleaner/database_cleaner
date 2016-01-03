module DatabaseCreator
  extend self

  def create_database_for(db_name)
    database_name = ::ConnectionHelpers.config_of(db_name)['default']['database']
    connection = ::ConnectionHelpers::ActiveRecord.build_anonymous_connection_for db_name
    connection.drop_database database_name rescue nil
    connection.create_database database_name
  end
end
