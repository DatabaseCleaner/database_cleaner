require 'support/database_creator'

::DatabaseCreator.create_database_for "postgres"
::DatabaseCreator.create_database_for "mysql"
::DatabaseCreator.create_database_for "mysql2"
