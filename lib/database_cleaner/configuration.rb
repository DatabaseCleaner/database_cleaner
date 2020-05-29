require 'database_cleaner/base'
require 'database_cleaner/deprecation'
require 'forwardable'

module DatabaseCleaner

  class NoORMDetected < StandardError; end
  class UnknownStrategySpecified < ArgumentError; end

  class Cleaners < Hash
    # FIXME this method conflates creation with lookup... both a command and a query. yuck.
    def [](orm, opts = {})
      raise NoORMDetected unless orm
      fetch([orm, opts]) { add_cleaner(orm, opts) }
    end 

    def strategy=(strategy)
      add_cleaner(:autodetect) if none?
      values.each { |cleaner| cleaner.strategy = strategy }
      remove_duplicates
    end

    def orm=(orm)
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.orm=` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      add_cleaner(:autodetect) if none?
      values.each { |cleaner| cleaner.orm = orm }
      remove_duplicates
    end

    # TODO privatize the following methods in 2.0

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

    def app_root
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.app_root` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner::ActiveRecord.config_file_location`, instead."
      @app_root ||= Dir.pwd
    end

    def app_root= value
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.app_root=` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner::ActiveRecord.config_file_location=`, instead."
      @app_root = value
    end

    def logger
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.logger` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::ERROR }
    end

    def logger= value
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.logger=` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      @logger = value
    end

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

    # TODO remove the following methods in 2.0

    def clean!
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.clean!` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner.clean`, instead."
      clean
    end

    def clean_with!(*args)
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.clean_with!` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner.clean_with`, instead."
      clean_with(*args)
    end

    def init_cleaners
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner.init_cleaners` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
    end

    def connections
      if DatabaseCleaner.called_externally?(__FILE__, caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner.connections` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner.cleaners.values`, instead."
      end
      add_cleaner(:autodetect) if @cleaners.none?
      @cleaners.values
    end

    # TODO privatize the following methods in 2.0

    def add_cleaner(orm, opts = {})
      if DatabaseCleaner.called_externally?(__FILE__, caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner.add_cleaner` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner.[]`, instead."
      end
      @cleaners.add_cleaner(orm, opts = {})
    end

    def remove_duplicates
      if DatabaseCleaner.called_externally?(__FILE__, caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner.remove_duplicates` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      end
      @cleaners.remove_duplicates
    end
  end
end
