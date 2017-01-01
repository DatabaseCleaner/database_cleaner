module DatabaseCleaner
  module Mongo
    module TruncationMixin

      def clean
        if @only
          collections.each { |c| c.send(truncate_method_name) if @only.include?(c.name) }
        else
          collections.each { |c| c.send(truncate_method_name) unless @tables_to_exclude.include?(c.name) }
        end
        true
      end

      private

      def collections
        database.collections.select { |c| c.name !~ /^system\./ }
      end

      def truncate_method_name
        # This constant doesn't exist in 1.8.x to 1.12.x versions
        defined?(::Mongo::VERSION) && ::Mongo::VERSION >= "2.0.0" ? :delete_many : :remove
      end
    end
  end
end
