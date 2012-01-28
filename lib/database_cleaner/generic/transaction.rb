module DatabaseCleaner
  module Generic
    module Transaction
      def initialize(opts = {})
        if !opts.empty?
          raise ArgumentError, "Options are not available for transaction strategies."
        end
      end
    end
  end
end
