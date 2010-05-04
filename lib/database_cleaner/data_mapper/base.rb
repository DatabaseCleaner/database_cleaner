module ActiveRecord
  module DataMapper
    def self.available_strategies
      %w[truncation transaction]
    end
  end
end