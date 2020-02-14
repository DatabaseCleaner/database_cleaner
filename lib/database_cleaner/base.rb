require 'database_cleaner/deprecation'
require 'database_cleaner/null_strategy'
require 'database_cleaner/safeguard'
require 'forwardable'

module DatabaseCleaner
  class Base
    include Comparable

    def <=>(other)
      [orm, db] <=> [other.orm, other.db]
    end

    def initialize(orm = :null, opts = {})
      self.orm = orm
      self.db = opts[:connection] || opts[:model] if opts.has_key?(:connection) || opts.has_key?(:model)
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

    def orm= orm
      raise ArgumentError if orm.nil?
      @orm = orm.to_sym
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
      strategy_module_name = strategy.to_s.capitalize
      orm_module.const_get(strategy_module_name)
    rescue NameError
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
    end

    def orm_module
      orm_module_name = camelize(orm)
      DatabaseCleaner.const_get(orm_module_name)
    end

    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      string.gsub!("/", "::")
      string
    end
  end
end
