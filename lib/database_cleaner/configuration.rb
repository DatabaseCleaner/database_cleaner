require 'database_cleaner/base'

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
    def [](orm,opts = {})
      raise NoORMDetected if orm.nil?
      @connections ||= []
      cleaner = DatabaseCleaner::Base.new(orm,opts)
      connections.push cleaner
      cleaner
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
      self.connections.each { |connection| connection.start }
    end
    
    def clean
      self.connections.each { |connection| connection.clean }
    end
    
    def clean_with(stratagem)
      self.connections.each { |connection| connection.clean_with stratagem }
    end
    
    def remove_duplicates
      temp = []
      @connections.each do |connect|
        temp.push connect unless temp.include? connect
      end
      @connections = temp
    end
  end       
end
