require 'database_cleaner/mongoid'

RSpec.describe DatabaseCleaner::Mongoid do
  it "has a default_strategy of truncation" do
    expect(described_class.default_strategy).to eq(:truncation)
  end
end

