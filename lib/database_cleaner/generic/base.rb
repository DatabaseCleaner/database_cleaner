module ::DatabaseCleaner
  module Generic
    module ConfigurableDB
      def db=(desired_db)
        @db = desired_db
      end

      def db
        @db || :unspecified
      end
    end

     module Base
       def self.included(base)
         base.extend(ClassMethods)
       end

       def db
         :unspecified
       end

       module ClassMethods
         def available_strategies
           %W[]
         end
       end
     end
   end
end
