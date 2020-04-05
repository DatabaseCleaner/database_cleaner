require 'database_cleaner/version'
require 'database_cleaner/configuration'
require 'database_cleaner/deprecation'
require 'forwardable'

module DatabaseCleaner
  class << self
    extend Forwardable
    delegate [
      :[],
      :strategy=,
      :orm=,
      :start,
      :clean,
      :clean_with,
      :cleaning,
    ] => :configuration

    attr_accessor :allow_remote_database_url, :allow_production, :url_whitelist

    def cleaners
      @cleaners ||= Cleaners.new
    end
    attr_writer :cleaners
  end
end
