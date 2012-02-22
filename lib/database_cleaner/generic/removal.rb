module ::DatabaseCleaner
  module Generic
    module Removal
      def start
        @list_of_objects_to_remove = []
      end


      def clean
        @list_of_objects_to_remove.each do |executor|
          executor.invoke
        end
      end


      def execute_at_clean(object=nil, method=nil, *args)
        @list_of_objects_to_remove ||= []
        @list_of_objects_to_remove << Executor.new(object, method, *args)
      end


      class Executor

        def initialize(object, method, *args)
          @object = object
          @method = method || self.class.removal_method
          @args = args
        end

        def invoke
          if @object.respond_to? @method
            @object.send(@method, *@args)
          else
            puts "Object #{object} does not respond to method #{@method}, ignoring cleanup for this object."
          end
        end

        class << self
          def removal_method= (method)
            @removal_method = method
          end

          def removal_method
            @removal_method || :delete
          end
        end
      end
    end
  end


  class << self

    # Mark an activerecord object to be removed from the database at clean time.
    # The arguments are used as follows:
    #
    # with a block:
    #       The block will be executed during clean. Any arguments passed in will be passed to the block
    # without a block:
    #       The first argument will be the object to destroy.
    #       The second argument, if provided, will be the method to call. Defaults to :delete if not provided
    #       Any further arguments will be passed to the above method.
    def mark_for_removal(*args, &block)
      if block_given?
        object = block
        method = :call
      else
        object = args.shift
        raise "Object to remove at clean must not be nil" if object.nil?
        method = args.shift
      end
      connections.each do |connection|
        if connection.strategy.respond_to? :execute_at_clean
          connection.strategy.execute_at_clean object, method, *args
        end
      end
    end

    # execute the passed in block when the removal strategy is cleaned.
    # any arguments passed in to this function will be passed to the block.
    def at_removal(*args, &block)
      connections.each do |connection|
        if connection.strategy.respond_to? :execute_at_clean
          connection.strategy.execute_at_clean block, :call, *args
        end
      end
    end

  end
end
