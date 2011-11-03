module ::DatabaseCleaner
   module Generic
     module Base

       def self.included(base)
         base.extend(ClassMethods)
       end

       def db
         :default
       end

       module ClassMethods
         def available_strategies
           %W[]
         end
       end
     end
   end
end
