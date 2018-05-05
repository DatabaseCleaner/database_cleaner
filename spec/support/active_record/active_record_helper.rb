require 'support/database_helper'

class ActiveRecordHelper < DatabaseHelper
  def setup
    Kernel.const_set "User", Class.new(ActiveRecord::Base)
    Kernel.const_set "Agent", Class.new(ActiveRecord::Base)
    super
  end

  def teardown
    super
    Kernel.send :remove_const, "User" if defined?(User)
    Kernel.send :remove_const, "Agent" if defined?(Agent)
  end

  def migrate
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'
  end

  def connection
    ActiveRecord::Base.connection
  end

  private

  def establish_connection(config = default_config)
    ActiveRecord::Base.establish_connection(config)
  end
end

