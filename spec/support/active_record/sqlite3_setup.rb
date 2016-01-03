require 'support/connection_helpers'
require 'support/database_creator'
require 'support/active_record/schema_setup'

module SQLite3Helper
  ADAPTER = 'sqlite3'

  puts "Active Record #{ActiveRecord::VERSION::STRING}, #{ADAPTER}"

  def active_record_sqlite3_setup
    ::ConnectionHelpers::ActiveRecord.build_connection_for ADAPTER
    ActiveRecord::Migrator.migrate 'spec/support/active_record/migrations'

    active_record_load_schema
  end

  def active_record_sqlite3_connection
    ActiveRecord::Base.connection
  end
end

RSpec.configure do |c|
  c.include SQLite3Helper
end
