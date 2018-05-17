require 'active_record'
require 'support/database_helper'

class ActiveRecordHelper < DatabaseHelper
  def setup
    Kernel.const_set "User", Class.new(ActiveRecord::Base)
    Kernel.const_set "Agent", Class.new(ActiveRecord::Base)

    super

    connection.execute "CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(255));"
    connection.execute "INSERT INTO schema_migrations VALUES (1), (2);"
  end

  def teardown
    connection.execute "DROP TABLE schema_migrations;"

    super

    Kernel.send :remove_const, "User" if defined?(User)
    Kernel.send :remove_const, "Agent" if defined?(Agent)
  end

  def connection
    ActiveRecord::Base.connection
  end

  private

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end
end

