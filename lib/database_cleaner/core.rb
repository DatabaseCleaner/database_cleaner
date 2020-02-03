require 'database_cleaner/version'
require 'database_cleaner/configuration'
require 'database_cleaner/deprecation'
require 'forwardable'

module DatabaseCleaner
  class << self
    extend Forwardable
    delegate [
      :[],
      :cleaners,
      :cleaners=,
      :strategy=,
      :orm=,
      :start,
      :clean,
      :clean_with,
      :cleaning,
    ] => :configuration

    attr_accessor :allow_remote_database_url, :allow_production, :url_whitelist

    private

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
