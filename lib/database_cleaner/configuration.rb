require 'database_cleaner/base'

module DatabaseCleaner

  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  class << self
    def init_cleaners
      @cleaners ||= {}
      # ghetto ordered hash.. maintains 1.8 compat and old API
      @connections ||= []
    end

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

    def add_cleaner(orm,opts = {})
      init_cleaners
      cleaner = DatabaseCleaner::Base.new(orm,opts)
      @cleaners[[orm, opts]] = cleaner
      @connections << cleaner
      cleaner
    end

    def app_root=(desired_root)
      @app_root = desired_root
    end

    def app_root
      @app_root || Dir.pwd
    end

    def connections
      # double yuck.. can't wait to deprecate this whole class...
      unless @cleaners
        autodetected = ::DatabaseCleaner::Base.new
        add_cleaner(autodetected.orm)
      end
      @connections
    end

    def logger=(log_source)
      @logger = log_source
    end

    def logger
      return @logger if @logger

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::ERROR
      @logger
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

    def clean_with(*args)
      connections.each { |connection| connection.clean_with(*args) }
    end

    alias clean_with! clean_with

    def remove_duplicates
      temp = []
      connections.each do |connect|
        temp.push connect unless temp.include? connect
      end
      @connections = temp
    end

    def orm_module(symbol)
      case symbol
        when :active_record
          DatabaseCleaner::ActiveRecord
        when :data_mapper
          DatabaseCleaner::DataMapper
        when :mongo
          DatabaseCleaner::Mongo
        when :mongoid
          DatabaseCleaner::Mongoid
        when :mongo_mapper
          DatabaseCleaner::MongoMapper
        when :moped
          DatabaseCleaner::Moped
        when :couch_potato
          DatabaseCleaner::CouchPotato
        when :sequel
          DatabaseCleaner::Sequel
        when :ohm
          DatabaseCleaner::Ohm
        when :redis
          DatabaseCleaner::Redis
      end
    end
  end
end
