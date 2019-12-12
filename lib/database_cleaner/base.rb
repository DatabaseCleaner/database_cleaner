require 'database_cleaner/null_strategy'
require 'database_cleaner/safeguard'

module DatabaseCleaner
  class Base
    include Comparable

    def <=>(other)
      [orm, db] <=> [other.orm, other.db]
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
      @strategy ||= NullStrategy.new
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
      case orm
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
        when :neo4j
          DatabaseCleaner::Neo4j
      end
    end

    def orm_strategy(strategy)
      orm_module.const_get(strategy.to_s.capitalize)
    rescue NameError
      $stderr.puts <<-TEXT
        Requiring the `database_cleaner` gem directly is deprecated, and will raise an error in database_cleaner 2.0. Instead, please require the specific gem (or gems) for your ORM.
        For example, replace `gem "database_cleaner"` with `gem "database_cleaner-#{orm}"` in your Gemfile.
      TEXT
      require_orm_strategy(orm, strategy)
      retry
    end

    def require_orm_strategy(orm, strategy)
      $LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../../adapters/database_cleaner-#{orm}/lib/database_cleaner/#{orm}")
      require "database_cleaner/#{orm}/#{strategy}"
    rescue LoadError
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
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
