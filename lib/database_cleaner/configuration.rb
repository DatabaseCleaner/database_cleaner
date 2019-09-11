require 'database_cleaner/base'

module DatabaseCleaner

  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  class Configuration
    def [](orm,opts = {})
      raise NoORMDetected unless orm
      init_cleaners
      # TODO: deprecate
      # this method conflates creation with lookup.  Both a command and a query. Yuck.
      if @cleaners.has_key? [orm, opts]
        @cleaners[[orm, opts]]
      else
        add_cleaner(orm, opts)
      end
    end 
    attr_accessor :app_root, :logger

    def app_root
      @app_root ||= Dir.pwd
    end

    def logger
      @logger ||= Logger.new(STDOUT).tap { |l| l.level = Logger::ERROR }
    end

    def strategy=(stratagem)
      connections.each { |connect| connect.strategy = stratagem }
      remove_duplicates
    end

    def orm=(orm)
      connections.each { |connect| connect.orm = orm }
      remove_duplicates
    end

    def start
      connections.each { |connection| connection.start }
    end

    def clean
      connections.each { |connection| connection.clean }
    end

    alias clean! clean

    def cleaning(&inner_block)
      connections.inject(inner_block) do |curr_block, connection|
        proc { connection.cleaning(&curr_block) }
      end.call
    end

    def clean_with(*args)
      connections.each { |connection| connection.clean_with(*args) }
    end

    alias clean_with! clean_with

    # TODO deprecate and then privatize the following methods:

    def init_cleaners
      @cleaners ||= {}
      # ghetto ordered hash.. maintains 1.8 compat and old API
      @connections ||= []
    end

    def add_cleaner(orm,opts = {})
      init_cleaners
      cleaner = DatabaseCleaner::Base.new(orm,opts)
      @cleaners[[orm, opts]] = cleaner
      @connections << cleaner
      cleaner
    end

    def connections
      # double yuck.. can't wait to deprecate this whole class...
      unless defined?(@cleaners) && @cleaners
        autodetected = ::DatabaseCleaner::Base.new
        add_cleaner(autodetected.orm)
      end
      @connections
    end

    def remove_duplicates
      temp = []
      connections.each do |connect|
        temp.push connect unless temp.include? connect
      end
      @connections = temp
    end
  end
end
