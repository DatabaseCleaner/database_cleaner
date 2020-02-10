require 'database_cleaner/deprecation'
require 'database_cleaner/null_strategy'
require 'database_cleaner/safeguard'
require 'database_cleaner/orm_autodetector'
require 'forwardable'

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
      self.strategy = orm_module && orm_module.default_strategy
      Safeguard.new.run
    end

    def db=(desired_db)
      @db = self.strategy_db = desired_db
    end

    def db
      @db ||= :default
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

    extend Forwardable
    delegate [:start, :clean, :cleaning] => :strategy

    def clean_with(*args)
      strategy = create_strategy(*args)
      set_strategy_db strategy, db
      strategy.clean
      strategy
    end

    # TODO remove the following methods in 2.0

    def auto_detected?
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].auto_detected?` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      @orm_autodetector.autodetected?
    end

    def autodetect_orm
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].autodetect_orm` is deprecated, and will be removed in database_cleaner 2.0 with no replacement."
      @orm_autodetector.orm
    end

    def clean!
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].clean!` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner[...].clean instead."
      clean
    end

    def clean_with!
      DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].clean_with!` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner[...].clean_with instead."
      clean_with
    end

    # TODO privatize the following methods in 2.0

    def strategy_db=(desired_db)
      if called_externally?(caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].strategy_db=` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner[...].db=` instead."
      end
      set_strategy_db(strategy, desired_db)
    end

    def set_strategy_db(strategy, desired_db)
      if called_externally?(caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].set_strategy_db=` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner[...].db=` instead."
      end
      if strategy.respond_to? :db=
        strategy.db = desired_db
      elsif desired_db != :default
        raise ArgumentError, "You must provide a strategy object that supports non default databases when you specify a database"
      end
    end

    def create_strategy(*args)
      if called_externally?(caller)
        DatabaseCleaner.deprecate "Calling `DatabaseCleaner[...].create_strategy` is deprecated, and will be removed in database_cleaner 2.0. Use `DatabaseCleaner[...].strategy=` instead."
      end
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    private

    def orm_module
      return unless [:active_record, :data_mapper, :mongo, :mongoid, :mongo_mapper, :moped, :couch_potato, :sequel, :ohm, :redis, :neo4j].include?(orm)
      load_adapter(orm) if !adapter_loaded?(orm)
      orm_module_name = ORMAutodetector::ORMS[orm]
      DatabaseCleaner.const_get(orm_module_name, false)
    end

    def adapter_loaded? orm
      $LOADED_FEATURES.grep(%r{/lib/database_cleaner/#{orm}\.rb$}).any?
    end

    def load_adapter orm
      $LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../../adapters/database_cleaner-#{orm}/lib")
      require "database_cleaner/#{orm}"
    end

    def orm_strategy(strategy)
      strategy_module_name = strategy.to_s.capitalize
      orm_module.const_get(strategy_module_name, false)
    rescue NameError
      if orm != :active_record
        DatabaseCleaner.deprecate <<-TEXT
          The #{orm_module} adapter has been extracted to its own gem: database_cleaner-#{orm}, and will be removed from database_cleaner in 2.0. To silence this message, please replace `gem "database_cleaner"` with `gem "database_cleaner-#{orm}"` in your Gemfile.
        TEXT
      end
      require_orm_strategy(orm, strategy)
      retry
    end

    def require_orm_strategy(orm, strategy)
      $LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/../../adapters/database_cleaner-#{orm}/lib")
      require "database_cleaner/#{orm}/#{strategy}"
    rescue LoadError
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
    end

    def called_externally?(caller)
      __FILE__ != caller.first.split(":").first
    end
  end
end
