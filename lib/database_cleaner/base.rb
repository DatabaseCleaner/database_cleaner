require 'database_cleaner/null_strategy'
require 'database_cleaner/safeguard'
module DatabaseCleaner
  class Base
    include Comparable

    def <=>(other)
      (self.orm <=> other.orm) == 0 ? self.db <=> other.db : self.orm <=> other.orm
    end

    def initialize(desired_orm = nil,opts = {})
      if [:autodetect, nil, "autodetect"].include?(desired_orm)
        autodetect
      else
        self.orm = desired_orm
      end
      self.db = opts[:connection] || opts[:model] if opts.has_key?(:connection) || opts.has_key?(:model)
      set_default_orm_strategy
      Safeguard.new.run
    end

    def db=(desired_db)
       self.strategy_db = desired_db
       @db = desired_db
    end

    def strategy_db=(desired_db)
      if strategy.respond_to? :db=
        strategy.db = desired_db
      elsif desired_db!= :default
        raise ArgumentError, "You must provide a strategy object that supports non default databases when you specify a database"
      end
    end

    def db
      @db ||= :default
    end

    def create_strategy(*args)
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    def clean_with(*args)
      strategy = create_strategy(*args)
      set_strategy_db strategy, self.db

      strategy.clean
      strategy
    end

    alias clean_with! clean_with

    def set_strategy_db(strategy, desired_db)
      if strategy.respond_to? :db=
        strategy.db = desired_db
      elsif desired_db != :default
        raise ArgumentError, "You must provide a strategy object that supports non default databases when you specify a database"
      end
    end

    def strategy=(args)
      strategy, *strategy_args = args
       if strategy.is_a?(Symbol)
          @strategy = create_strategy(*args)
       elsif strategy_args.empty?
         @strategy = strategy
       else
         raise ArgumentError, "You must provide a strategy object, or a symbol for a known strategy along with initialization params."
       end

       set_strategy_db @strategy, self.db

       @strategy
    end

    def strategy
      @strategy ||= NullStrategy
    end

    def orm=(desired_orm)
      @orm = desired_orm.to_sym
    end

    def orm
      @orm || autodetect
    end

    def start
      strategy.start
    end

    def clean
      strategy.clean
    end

    alias clean! clean

    def cleaning(&block)
      strategy.cleaning(&block)
    end

    def auto_detected?
      !!@autodetected
    end

    def autodetect_orm
      if defined? ::ActiveRecord
        :active_record
      elsif defined? ::DataMapper
        :data_mapper
      elsif defined? ::MongoMapper
        :mongo_mapper
      elsif defined? ::Mongoid
        :mongoid
      elsif defined? ::CouchPotato
        :couch_potato
      elsif defined? ::Sequel
        :sequel
      elsif defined? ::Moped
        :moped
      elsif defined? ::Ohm
        :ohm
      elsif defined? ::Redis
        :redis
      elsif defined? ::Neo4j
        :neo4j
      end
    end

    private

    def orm_module
      ::DatabaseCleaner.orm_module(orm)
    end

    def orm_strategy(strategy)
      require "database_cleaner/#{orm.to_s}/#{strategy.to_s}"
      orm_module.const_get(strategy.to_s.capitalize)
    rescue LoadError
      if orm_module.respond_to? :available_strategies
        raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
      else
        raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!"
      end
    end

    def autodetect
      @autodetected = true

      @orm ||= autodetect_orm ||
               raise(NoORMDetected, "No known ORM was detected!  Is ActiveRecord, DataMapper, Sequel, MongoMapper, Mongoid, Moped, or CouchPotato, Redis or Ohm loaded?")
    end

    def set_default_orm_strategy
      case orm
      when :active_record, :data_mapper, :sequel
        self.strategy = :transaction
      when :mongo_mapper, :mongoid, :couch_potato, :moped, :ohm, :redis
        self.strategy = :truncation
      when :neo4j
        self.strategy = :transaction
      end
    end
  end
end
