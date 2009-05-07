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
      %w[truncation transaction]
    end
  end

  class << self

    def create_strategy(*args)
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    def clean_with(*args)
      strategy = create_strategy(*args)
      strategy.clean
      strategy
    end

    def strategy=(args)
      strategy, *strategy_args = args
       if strategy.is_a?(Symbol)
          @strategy = create_strategy(*args)
       elsif strategy_args.empty?
         @strategy = strategy
       else
         raise ArgumentError, "You must provide a strategy object, or a symbol for a know strategy along with initialization params."
       end
    end

    def orm=(orm_string)
      @orm = orm_string
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
      @orm ||=begin
        if defined? ::ActiveRecord
          'active_record'
        elsif defined? ::DataMapper
          'data_mapper'
        else
          raise NoORMDetected, "No known ORM was detected!  Is ActiveRecord or DataMapper loaded?"
        end
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
  
  
  # common base class for truncation strategies
  
  class TruncationBase
    
    def initialize(options = {})
      if !options.empty? && !(options.keys - [:only, :except]).empty?
        raise ArgumentError, "The only valid options are :only and :except. You specified #{options.keys.join(',')}."
      end
      if options.has_key?(:only) && options.has_key?(:except)
        raise ArgumentError, "You may only specify either :only or :either.  Doing both doesn't really make sense does it?" 
      end

      @only = options[:only]
      @tables_to_exclude = (options[:except] || [])
      if migration_storage = migration_storage_name
        @tables_to_exclude << migration_storage
      end
    end

    def start
      # no-op
    end

    def clean
      raise NotImplementedError
    end
    

    private

    def tables_to_truncate
      raise NotImplementedError
    end
    
    # overwrite in subclasses
    # default implementation given because migration storage need not be present
    def migration_storage_name
      nil
    end
    
  end

end
