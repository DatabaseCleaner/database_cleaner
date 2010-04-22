module ::DatabaseCleaner
   module Generic
     module Strategy
       
       def self.included(base)
         base.extend(ClassMethods)
         base.send(:include, InstanceMethods)
       end

       module InstanceMethods
         def initialize(db = :default) 
           @db = db
         end
         
         def db=(desired_db)
           @db = desired_db
         end

         def db
           @db
         end

         def connection_klass
           raise NotImplementedError
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