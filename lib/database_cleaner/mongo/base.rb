module DatabaseCleaner
  module Mongo
    def self.available_strategies
      %w[truncation]
    end
  end
end
