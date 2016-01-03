require 'support/connection_helpers'
require 'support/database_creator'
require 'support/active_record/schema_setup'

module MySQL2Helper
  ADAPTER = 'mysql2'

  puts "Active Record #{ActiveRecord::VERSION::STRING}, #{ADAPTER}"

  def active_record_mysql2_setup
    ::DatabaseCreator.create_database_for ADAPTER
    ::ConnectionHelpers::ActiveRecord.build_connection_for ADAPTER
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'

    active_record_load_schema
  end

  def active_record_mysql2_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include MySQL2Helper
end
