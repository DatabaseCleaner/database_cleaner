require 'database_cleaner/base'
require 'database_cleaner/active_record/adaptor'
require 'database_cleaner/data_mapper/adaptor'
#require 'database_cleaner/mongo_mapper/adaptor'
#require 'database_cleaner/couch_potato/adaptor'

module DatabaseCleaner

  class NoStrategySetError < StandardError;   end
  class NoORMDetected < StandardError;   end
  class UnknownStrategySpecified < ArgumentError;   end

 
  # 
  # module MongoMapper
  #   def self.available_strategies
  #     %w[truncation]
  #   end
  # end
  # 
  # module CouchPotato
  #   def self.available_strategies
  #     %w[truncation]
  #   end
  # end      
  
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
      self.connections.each { |connect| connect.strategy = stratagem }
      remove_duplicates
    end
    
    def orm=(orm)
      self.connections.each { |connect| connect.orm = orm }
      remove_duplicates
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
      self.connections.each do |connect|
        temp.push connect unless temp.include? connect
      end
      @connections = temp
    end
  end       
end
