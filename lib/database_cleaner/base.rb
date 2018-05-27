require 'database_cleaner/null_strategy'
require 'database_cleaner/safeguard'
require 'database_cleaner/orm_autodetector'
require 'active_support/core_ext/string/inflections'

module DatabaseCleaner
  class Base
    include Comparable

    def <=>(other)
      [orm, db] <=> [other.orm, other.db]
    end

    def initialize(desired_orm = nil, opts = {})
      @orm_autodetector = ORMAutodetector.new
      self.orm = desired_orm
      self.db = opts[:connection] || opts[:model] if opts.has_key?(:connection) || opts.has_key?(:model)
      self.strategy = default_orm_strategy
      Safeguard.new.run
    end

    def db=(desired_db)
      @db = self.strategy_db = desired_db
    end

    def strategy_db=(desired_db)
      set_strategy_db(strategy, desired_db)
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
      set_strategy_db strategy, db
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
      @strategy = if strategy.is_a?(Symbol)
        create_strategy(*args)
      elsif strategy_args.empty?
        strategy
      else
        raise ArgumentError, "You must provide a strategy object, or a symbol for a known strategy along with initialization params."
      end

      set_strategy_db @strategy, db
    end

    def strategy
      @strategy ||= NullStrategy.new
    end

    attr_reader :orm

    def orm=(desired_orm)
      @orm = (desired_orm || :autodetect).to_sym
      @orm = @orm_autodetector.orm if @orm == :autodetect
    end

    def auto_detected?
      @orm_autodetector.autodetected?
    end

    def autodetect_orm
      @orm_autodetector.orm
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

    private

    def orm_module
      return unless [:active_record, :data_mapper, :mongo, :mongoid, :mongo_mapper, :moped, :couch_potato, :sequel, :ohm, :redis, :neo4j].include?(orm)
      DatabaseCleaner.const_get(orm.to_s.camelize)
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

    def default_orm_strategy
      case orm
      when :active_record, :data_mapper, :sequel, :neo4j
        :transaction
      when :mongo_mapper, :mongoid, :couch_potato, :moped, :ohm, :redis
        :truncation
      end
    end
  end
end
