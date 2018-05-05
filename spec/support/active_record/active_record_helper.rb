require 'support/database_helper'
require 'support/active_record/schema_setup'

class ActiveRecordHelper < DatabaseHelper
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

