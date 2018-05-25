$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require 'database_cleaner/configuration'
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
      :strategy=,
      :orm=,
      :start,
      :clean,
      :clean_with,
      :cleaning,

      # TODO deprecate
      :clean!,
      :clean_with!,

      # TODO deprecate and then privatize the following methods:

      :init_cleaners,
      :add_cleaner,
      :connections,
      :remove_duplicates,
    ] => :configuration

    attr_accessor :allow_remote_database_url, :allow_production, :url_whitelist

    def can_detect_orm?
      DatabaseCleaner::Base.autodetect_orm
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
