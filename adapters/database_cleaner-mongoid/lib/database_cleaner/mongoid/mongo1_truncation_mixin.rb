module DatabaseCleaner
  module Mongoid
    module Mongo1TruncationMixin
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
        # This constant only exists in the 2.x series.
        defined?(::Mongo::VERSION) ? :delete_many : :remove
      end
    end
  end
end

