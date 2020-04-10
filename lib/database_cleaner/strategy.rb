# Abstract strategy class for orm adapter gems to subclass

module DatabaseCleaner
  class Strategy
    # Override this method if the strategy accepts options
    def initialize(options=nil)
      if options
        name = self.class.name.sub("DatabaseCleaner::","").sub("::"," ") # e.g. "ActiveRecord Transaction"
        raise ArgumentError, "No options are available for the #{name} strategy."
      end
    end

    def db
      @db ||= :default
    end
    attr_writer :db

    # Override this method to start a database transaction if the strategy uses them
    def start
    end

    # Override this method with the actual cleaning procedure. Its the only mandatory method implementation.
    def clean
      raise NotImplementedError
    end

    def cleaning(&block)
      begin
        start
        yield
      ensure
        clean
      end
    end

    private

    # Optional helper method for use in strategies with :only and :except options
    def tables_to_clean all_tables, only: [], except: []
      if only.any?
        if except.any?
          raise ArgumentError, "You may only specify either :only or :except.  Doing both doesn't really make sense does it?"
        end
        only
      else
        all_tables - except
      end
    end
  end
end
