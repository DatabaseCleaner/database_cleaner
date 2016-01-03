require "active_record"

module ConnectionHelpers
  module ActiveRecord
    extend self

    def build_connection_for(db_name)
      config = configuration_of db_name
      active_record_connection config
    end

    def build_anonymous_connection_for(db_name)
      config = anonymous_configuration_of db_name
      active_record_connection config
    end

    private
    def active_record_connection(db_config)
      begin
        ::ActiveRecord::Base.establish_connection(db_config)
        ::ActiveRecord::Base.connection
      rescue Exception => e
        $stderr.puts e, *(e.backtrace)
        $stderr.puts "Couldn't create database for #{db_config.inspect}"
      end
    end

    def configuration_of(db_name)
      ConnectionHelpers.config_of(db_name)['default']
    end

    def anonymous_configuration_of(db_name)
      database_name = anonymous_database_name_for(db_name)
      configuration_of(db_name).merge('database' => database_name, 'schema_search_path' => 'public')
    end

    def anonymous_database_name_for(db_name)
      db_name == 'mysql2' ? nil : db_name
    end
  end
end
