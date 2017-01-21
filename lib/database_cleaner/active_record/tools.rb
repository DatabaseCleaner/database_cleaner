
module DatabaseCleaner
  module ActiveRecord
    module Tools

      private

      def _filter_tables_from_ids_param(tables, ids)
        if ids.is_a? TrueClass
          tables
        elsif ids.is_a? Array
          tables & ids.collect(&:to_s)
        elsif ids.is_a? Hash
          tables & ids.keys.collect(&:to_s)
        else
          []
        end
      end
    end
  end
end