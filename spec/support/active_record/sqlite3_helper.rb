require 'support/active_record/active_record_helper'

class SQLite3Helper < ActiveRecordHelper
  puts "Active Record #{ActiveRecord::VERSION::STRING}, sqlite3"

  private

  def default_config
    db_config['sqlite3']
  end

  def create_db
    # NO-OP
  end

  def drop_db
    File.unlink(db_config['sqlite3']['database'])
  rescue Errno::ENOENT
  end
end

