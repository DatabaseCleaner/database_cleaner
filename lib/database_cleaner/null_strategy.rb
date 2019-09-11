module DatabaseCleaner
  class NullStrategy
    def start
      # no-op
    end
    
    def db=(connection)
      # no-op
    end
     
    def clean
      # no-op
    end

    def cleaning(&block)
      # no-op
      yield
    end
  end
end
