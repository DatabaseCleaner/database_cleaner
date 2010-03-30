module DatabaseCleaner

  class NoStrategySetError < StandardError;   end
  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

  module ActiveRecord
    def self.available_strategies
      %w[truncation transaction]
    end
    
    def self.connection_klasses
      @klasses || [::ActiveRecord::Base]
    end
    
    def self.connection_klasses=(other)
      other.concat [::ActiveRecord::Base] unless other.include? ::ActiveRecord::Base
      @klasses = other
    end
  end

  module DataMapper
    def self.available_strategies
      %w[truncation transaction]
    end
  end
  
  module MongoMapper
    def self.available_strategies
      %w[truncation]
    end
  end

  module CouchPotato
    def self.available_strategies
      %w[truncation]
    end
  end
  
  class << self  
    def [](orm)
      raise NoORMDetected if orm.nil?
      DatabaseCleaner::Base.new(orm)
    end

    def connections
      @connections ||= [::DatabaseCleaner::Base.new]
    end
    
    def strategy=(stratagem)
      self.connections.first.strategy = stratagem
    end
    
    def orm=(orm)
      self.connections.first.orm = orm
    end
    
    def start
      self.connections.first.start
    end
    
    def clean
      self.connections.first.clean
    end
    
    def clean_with(stratagem)
      self.connections.first.clean_with stratagem
    end
  end       
  
  class Base
    
    def initialize(desired_orm = nil)
      if desired_orm == :autodetect || desired_orm.nil?
        autodetect 
      else
        self.orm = desired_orm
      end
    end
      
    def create_strategy(*args)
      strategy, *strategy_args = args
      orm_strategy(strategy).new(*strategy_args)
    end

    def clean_with(*args)
      strategy = create_strategy(*args)
      strategy.clean
      strategy
    end

    alias clean_with! clean_with

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

    def orm=(desired_orm)
      @orm = desired_orm
    end

    def start
      strategy.start
    end

    def clean
      strategy.clean
    end

    alias clean! clean
    
    def orm
      @orm || autodetect
    end
    
    def auto_detected
      return true unless @autodetected.nil?
    end
    
    private

    def strategy
      return @strategy if @strategy
      raise NoStrategySetError, "Please set a strategy with DatabaseCleaner.strategy=."
    end
    
    def orm_module
      ::DatabaseCleaner.orm_module(orm)
    end
     
    def orm_strategy(strategy)
      require "database_cleaner/#{orm.to_s}/#{strategy.to_s}"
      orm_module.const_get(strategy.to_s.capitalize)
    rescue LoadError => e
      raise UnknownStrategySpecified, "The '#{strategy}' strategy does not exist for the #{orm} ORM!  Available strategies: #{orm_module.available_strategies.join(', ')}"
    end
    
    def autodetect
      @orm ||= begin
        @autodetected = true
        if defined? ::ActiveRecord
          :active_record
        elsif defined? ::DataMapper
          :data_mapper
        elsif defined? ::MongoMapper
          :mongo_mapper
        elsif defined? ::CouchPotato
          :couch_potato
        else
          raise NoORMDetected, "No known ORM was detected!  Is ActiveRecord, DataMapper, MongoMapper or CouchPotato loaded?"
        end
      end
    end
    
    def orm_module
      case orm
        when :active_record
          DatabaseCleaner::ActiveRecord
        when :data_mapper
          DatabaseCleaner::DataMapper
        when :mongo_mapper
          DatabaseCleaner::MongoMapper
        when :couch_potato
          DatabaseCleaner::CouchPotato
      end
    end
  end

end
