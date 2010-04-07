module DatabaseCleaner
  module StrategyBase
    def db=(desired_db)
      @db = desired_db
    end
    
    def db
      @db || :default
    end
  end
end