require 'mongo'
require 'moped'

module ConnectionHelpers
  module Mongo
    extend self

    def build_connection
      @mongodb ||= ::Mongo::Connection.new host, port
    end

    def build_moped_connection
      ::Moped::Session.new(["#{host}:#{port}"], :database => database_name)
    end

    def database_name
      ConnectionHelpers.config_of('mongodb')['database']
    end

    def host_port
      "#{host}:#{port}"
    end

    private
    def host
      ConnectionHelpers.config_of('mongodb')['host']
    end

    def port
      ConnectionHelpers.config_of('mongodb')['port']
    end
  end
end
