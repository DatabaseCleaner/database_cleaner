require 'database_cleaner/moped'

RSpec.describe DatabaseCleaner::Moped do
  it "has a default_strategy of truncation" do
    expect(described_class.default_strategy).to eq(:truncation)
  end
end

