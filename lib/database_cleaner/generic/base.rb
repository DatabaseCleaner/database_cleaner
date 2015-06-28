module ::DatabaseCleaner
  module Generic
    module Base

      def self.included(base)
        base.extend(ClassMethods)
      end

      def db
        :default
      end

      def cleaning(&block)
        begin
          start
          yield
        ensure
          clean
        end
      end

      module ClassMethods
        def available_strategies
          %W[]
        end
      end
    end
  end
end
