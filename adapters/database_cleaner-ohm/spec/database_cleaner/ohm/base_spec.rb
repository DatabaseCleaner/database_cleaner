require 'database_cleaner/ohm'

RSpec.describe DatabaseCleaner::Ohm do
  it "has a default_strategy of truncation" do
    expect(described_class.default_strategy).to eq(:truncation)
  end
end

