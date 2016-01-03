require "data_mapper"

module ConnectionHelpers
  module DataMapper
    extend self

    def build_connection
      begin
        @connection ||= ::DataMapper.setup(:default, configuration)
      rescue Exception => e
        $stderr.puts e, *(e.backtrace)
        $stderr.puts "Couldn't create database for #{configuration.inspect}"
      end
    end

    private
    def configuration
      ConnectionHelpers.config_of("sqlite3")['default']
        .merge('database' => 'sqlite3', 'schema_search_path' => 'public')
    end
  end
end
