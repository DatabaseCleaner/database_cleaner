require "sequel"

module ConnectionHelpers
  module Sequel
    extend self

    def build_connection_for(db_name)
      @connections ||= {}
      @connections[db_name] ||= ::Sequel.connect config_for(db_name)
    end

    private
    def config_for(db_name)
      default_config = ConnectionHelpers.config_of(db_name)['default']

      default_config.merge(
        'adapter' => adapter_for(db_name)
      )
    end

    def adapter_for(db_name)
      db_config = ConnectionHelpers.config_of(db_name)
      db_config['sequel_adapter'] || db_config['default']['adapter']
    end
  end
end
