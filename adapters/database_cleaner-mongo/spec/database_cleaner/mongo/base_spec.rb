require 'database_cleaner/mongo'

RSpec.describe DatabaseCleaner::Mongo do
  it "has a default_strategy of truncation" do
    expect(described_class.default_strategy).to eq(:truncation)
  end
end

