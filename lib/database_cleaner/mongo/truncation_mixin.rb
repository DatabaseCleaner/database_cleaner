module DatabaseCleaner
  module Mongo
    module TruncationMixin

      def clean
        if @only
          collections.each { |c| puts c.send(truncate_method_name) if @only.include?(c.name) }
        else
          collections.each { |c| puts c.send(truncate_method_name) unless @tables_to_exclude.include?(c.name) }
        end
        wait_for_truncations_to_finish
        true
      end

      private

      def collections
        database.collections.select { |c| c.name !~ /^system\./ }
      end

      def truncate_method_name
        # This constant only exists in the 2.x series.
        defined?(::Mongo::VERSION) ? :delete_many : :remove
      end

      def wait_for_truncations_to_finish
        database.get_last_error
      end
    end
  end
end
