require 'database_cleaner/version'
require 'database_cleaner/cleaners'
require 'forwardable'

module DatabaseCleaner
  class << self
    extend Forwardable
    delegate [
      :[],
      :strategy,
      :strategy=,
      :start,
      :clean,
      :clean_with,
      :cleaning,
    ] => :cleaners

    attr_accessor :allow_remote_database_url, :allow_non_test_env, :url_allowlist

    alias :url_whitelist :url_allowlist
    alias :url_whitelist= :url_allowlist=

    def cleaners
      @cleaners ||= Cleaners.new
    end
    attr_writer :cleaners
  end
end
