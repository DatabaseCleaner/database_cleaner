require 'database_cleaner/base'
require 'database_cleaner/deprecation'
require 'forwardable'

module DatabaseCleaner

  class UnknownStrategySpecified < ArgumentError; end

  class Cleaners < Hash
    # FIXME this method conflates creation with lookup... both a command and a query. yuck.
    def [](orm, opts = {})
      raise ArgumentError if orm.nil?
      fetch([orm, opts]) { add_cleaner(orm, opts) }
    end 

    def strategy=(strategy)
      add_cleaner(:autodetect) if none?
      values.each { |cleaner| cleaner.strategy = strategy }
      remove_duplicates
    end

    def orm=(orm)
      add_cleaner(:autodetect) if none?
      values.each { |cleaner| cleaner.orm = orm }
      remove_duplicates
    end

    private

    def add_cleaner(orm, opts = {})
      self[[orm, opts]] = ::DatabaseCleaner::Base.new(orm, opts)
    end

    def remove_duplicates
      replace(reduce(Cleaners.new) do |cleaners, (key, value)|
        cleaners[key] = value unless cleaners.values.include?(value)
        cleaners
      end)
    end
  end

  class Configuration
    def initialize
      @cleaners ||= Cleaners.new
    end

    extend Forwardable
    delegate [
      :[],
      :strategy=,
      :orm=,
    ] => :cleaners

    attr_accessor :cleaners

    def start
      connections.each { |connection| connection.start }
    end

    def clean
      connections.each { |connection| connection.clean }
    end

    def cleaning(&inner_block)
      connections.inject(inner_block) do |curr_block, connection|
        proc { connection.cleaning(&curr_block) }
      end.call
    end

    def clean_with(*args)
      connections.each { |connection| connection.clean_with(*args) }
    end

    private

    def connections
      @cleaners.values
    end

    def add_cleaner(orm, opts = {})
      @cleaners.add_cleaner(orm, opts = {})
    end

    def remove_duplicates
      @cleaners.remove_duplicates
    end
  end
end
