$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require 'database_cleaner/configuration'

module DatabaseCleaner
  class << self
    attr_accessor :allow_remote_database_url, :allow_production

    def can_detect_orm?
      DatabaseCleaner::Base.autodetect_orm
    end
  end
end
