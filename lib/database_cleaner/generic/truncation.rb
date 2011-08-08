module DatabaseCleaner
  module Generic
    module Truncation
      def self.included(base)
       base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        attr_reader :tables_to_include, :tables_to_always_include, :tables_to_exclude, :strategy_options

        def all_tables
          connection.tables
        end

        def tables_to_include
          only_tables.empty? ? all_tables : only_tables
        end

        def all_tables_to_include
          include_list = tables_to_include + tables_to_always_include
          list = include_list.empty? ? all_tables : include_list
          list.flatten.compact.uniq
        end

        def only_tables
          @only
        end

        def tables_to_affect
          @tables
        end

        def tables_to_affect= tables
          @tables = tables
        end

        def initialize(opts={})
          if !opts.empty? && !(opts.keys - [:only, :except, :include]).empty?
            raise ArgumentError, "The only valid options are :only, :except and :include. You specified #{opts.keys.join(',')}."
          end
          if opts.has_key?(:only) && opts.has_key?(:except)
            raise ArgumentError, "You may only specify either :only or :either.  Doing both doesn't really make sense does it?"
          end

          @strategy_options = opts.dup
          @only = (opts[:only] || []).dup
          @tables_to_exclude = (opts[:except] || []).dup

          @tables_to_always_include = (opts[:include] || []).map {|n| n == 'migrations' ? migration_storage_name : n} 

          # allow to explicitl include affecting the migrations table if present in :include list of tables as 'migrations'
          @tables_to_exclude << special_tables_to_exclude
        end

        def special_tables_to_exclude
          migration_storage_name unless include_migrations?
        end

        def include_migrations?
          (strategy_options[:include] || []).include?('migrations') || migration_storage_name.nil?
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
          def migration_storage_name
            nil
          end
      end
    end
  end
end
