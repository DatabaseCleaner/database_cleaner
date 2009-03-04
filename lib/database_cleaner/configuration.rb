module DatabaseCleaner
 
  class NoStrategySetError < StandardError;   end
  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  module ActiveRecord
    def self.available_strategies
      %w[truncation transaction]
    end
  end

  module DataMapper
    def self.available_strategies
      %w[]
    end
  end

  class << self
    def strategy=(args)
      strategy, *strategy_args = args
       if strategy.is_a?(Symbol)
          @strategy = orm_strategy(strategy).new(*strategy_args)
       else
         @strategy = strategy
       end
    end

    def start
      strategy.start
    end

    def clean
      strategy.clean
    end

    private

    def strategy
      return @strategy if @strategy
      raise NoStrategySetError, "Please set a strategy with DatabaseCleaner.strategy=."
    end

    def orm_strategy(strategy)
      require "database_cleaner/#{orm}/#{strategy}"
      orm_module.const_get(strategy.to_s.capitalize)
    rescue LoadError => e
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
    end


    def orm
      if defined? ::ActiveRecord
        'active_record'
      elsif defined? ::DataMapper
        'data_mapper'
      else
        raise NoORMDetected, "No known ORM was detected!  Is ActiveRecord or DataMapper loaded?"
      end
    end


    def orm_module
      case orm
      when 'active_record'
        DatabaseCleaner::ActiveRecord
      when 'data_mapper'
        DatabaseCleaner::DataMapper
      end
    end

  end

end
