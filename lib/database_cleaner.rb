$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require 'database_cleaner/version'
require 'database_cleaner/configuration'
require 'database_cleaner/deprecation'
require 'forwardable'

module DatabaseCleaner
  class << self
    extend Forwardable
    delegate [
      :[],
      :app_root=,
      :app_root,
      :logger=,
      :logger,
      :cleaners,
      :cleaners=,
      :strategy=,
      :orm=,
      :start,
      :clean,
      :clean_with,
      :cleaning,

      # TODO remove in 2.0
      :clean!,
      :clean_with!,
      :init_cleaners,
      :add_cleaner,
      :connections,
      :remove_duplicates,
    ] => :configuration

    attr_accessor :allow_remote_database_url, :allow_production, :url_whitelist

    def can_detect_orm?
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.can_detect_orm?` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      DatabaseCleaner::Base.autodetect_orm
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
