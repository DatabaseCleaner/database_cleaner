$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require 'database_cleaner/configuration'

module DatabaseCleaner
  def self.can_detect_orm?
    DatabaseCleaner::Base.autodetect_orm
  end
end
