require 'database_cleaner/null_strategy'
require 'database_cleaner/strategy'
require 'database_cleaner/string_helper'
require 'forwardable'

module DatabaseCleaner
  class UnknownStrategySpecified < ArgumentError; end

  class Cleaner
    def self.available_strategies(orm_module)
      strategies = []

      # introspect publicly available constants for descendents of Strategy to get list of strategies
      # ignore classes named Base, because it's a common name for a shared base class that adds ORM access stuff to Strategy before being inherited by final concrete class
      # if you're writing an adapter and this method is falsely returning an internal constant that isn't a valid strategy, consider making it private with Module#private_constant.
      orm_module.constants.each do |constant_name|
        next if constant_name == :Base

        ancestors = orm_module.const_get(constant_name).ancestors rescue []
        next unless ancestors.include?(DatabaseCleaner::Strategy)

        strategies << StringHelper.underscore(constant_name).to_sym
      end

      strategies
    end

    include Comparable

    def <=>(other)
      [orm, db] <=> [other.orm, other.db]
    end

    def initialize(orm, db: nil)
      @orm = orm
      self.db = db
    end

    attr_reader :orm

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

    extend Forwardable
    delegate [:start, :clean, :cleaning] => :strategy

    def clean_with(*args)
      strategy = create_strategy(*args)
      set_strategy_db strategy, db
      strategy.clean
      strategy
    end

    private

    def strategy_db=(desired_db)
      set_strategy_db(strategy, desired_db)
    end

    def set_strategy_db(strategy, desired_db)
      if strategy.respond_to? :db=
        strategy.db = desired_db
      elsif desired_db != :default
        raise ArgumentError, "You must provide a strategy object that supports non default databases when you specify a database"
      end
    end

    def create_strategy(*args)
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    def orm_strategy(strategy)
      strategy_module_name = StringHelper.camelize(strategy)
      orm_module.const_get(strategy_module_name)
    rescue NameError
      available_strategies = self.class.available_strategies(orm_module)
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{available_strategies.join(', ')}"
    end

    def orm_module
      orm_module_name = StringHelper.camelize(orm)
      DatabaseCleaner.const_get(orm_module_name)
    end
  end
end
