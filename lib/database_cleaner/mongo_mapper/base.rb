module DatabaseCleaner
  module MongoMapper
    def self.available_strategies
      %w[truncation]
    end
  end
end