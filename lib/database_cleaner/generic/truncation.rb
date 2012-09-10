module DatabaseCleaner
  module Generic
    module Truncation
      def initialize(opts={})
        if !opts.empty? && !(opts.keys - [:only, :except, :pre_count, :reset_ids]).empty?
          raise ArgumentError, "The only valid options are :only, :except, :pre_count or :reset_ids. You specified #{opts.keys.join(',')}."
        end
        if opts.has_key?(:only) && opts.has_key?(:except)
          raise ArgumentError, "You may only specify either :only or :except.  Doing both doesn't really make sense does it?"
        end

        @only = opts[:only]
        @tables_to_exclude = (opts[:except] || []).dup
        @tables_to_exclude += migration_storage_names
        @pre_count = opts[:pre_count]
        @reset_ids = opts[:reset_ids]
      end

      def start
        #included for compatability reasons, do nothing if you don't need to
      end

      def clean
        raise NotImplementedError
      end

      private
      def tables_to_truncate
        raise NotImplementedError
      end

      # overwrite in subclasses
      # default implementation given because migration storage need not be present
      def migration_storage_names
        %w[]
      end
    end
  end
end
