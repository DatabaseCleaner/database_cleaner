module DatabaseCleaner
  module Generic
    module Dataholder
      def checktarget(target)
        if ($strike_targets.include?(target.class.table_name.upcase))
          $vips.push(target)
        end
      end
    end
    module Surgicalstrike
      def initialize(opts={})
        if !opts.empty? && !(opts.keys - [:only, :except]).empty?
          raise ArgumentError, "The only valid options are :only and :except. You specified #{opts.keys.join(',')}."
        end
        if opts.has_key?(:only) && opts.has_key?(:except)
          raise ArgumentError, "You may only specify either :only or :except.  Doing both doesn't really make sense does it?"
        end

        @only = opts[:only]
        @tables_to_exclude = (opts[:except] || []).dup
        @tables_to_exclude << migration_storage_name if migration_storage_name
      end

      def start
        raise NotImplementedError
      end

      def clean
        raise NotImplementedError
      end

      private

      def tables_to_strike(connection)
        raise NotImplementedError
      end

      # overwrite in subclasses
      # default implementation given because migration storage need not be present
      def migration_storage_name
        nil
      end
    end
  end
end
