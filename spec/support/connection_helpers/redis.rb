require 'redis'
require 'ohm'

module ConnectionHelpers
  module Redis
    extend self

    def build_connection
      @conncetion ||= ::Redis.new ConnectionHelpers.config_of('redis')
    end

    def build_ohm_connection
      if @ohm_connection.nil?
        ::Ohm.connect :url => url
        @ohm_connection = ::Ohm.redis
      end
    end

    def url
      redis = ConnectionHelpers.config_of('redis')
      "redis://#{redis['host']}:#{redis['port']}"
    end
  end
end
