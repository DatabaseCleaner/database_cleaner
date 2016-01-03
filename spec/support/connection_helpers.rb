require 'yaml'
require "support/connection_helpers/redis"
require "support/connection_helpers/mongo"
require "support/connection_helpers/sequel"
require "support/connection_helpers/data_mapper"
require "support/connection_helpers/active_record"

module ConnectionHelpers
  SPEC_ROOT = File.join File.dirname(__FILE__), ".."

  def self.config_of(db_name)
    ::YAML::load(File.open(File.join(SPEC_ROOT, "support/database.yml")))[db_name]
  end
end
