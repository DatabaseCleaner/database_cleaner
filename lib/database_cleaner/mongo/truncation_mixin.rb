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
        defined?(::Mongo::VERSION) && ::Mongo::VERSION >= "2" ? :delete_many : :remove
      end
    end
  end
end
