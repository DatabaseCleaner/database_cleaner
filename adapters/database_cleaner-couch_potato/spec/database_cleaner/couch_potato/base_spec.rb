require 'database_cleaner/couch_potato'

RSpec.describe DatabaseCleaner::CouchPotato do
  it "has a default_strategy of truncation" do
    expect(described_class.default_strategy).to eq(:truncation)
  end
end

