RSpec.shared_examples_for "a generic strategy" do
  it { is_expected.to respond_to(:db)  }
end

RSpec.shared_examples_for "a generic truncation strategy" do
  it { is_expected.to respond_to(:start) }
  it { is_expected.to respond_to(:clean) }
  it { is_expected.to respond_to(:cleaning) }
end

RSpec.shared_examples_for "a generic transaction strategy" do
  it { is_expected.to respond_to(:start) }
  it { is_expected.to respond_to(:clean) }
  it { is_expected.to respond_to(:cleaning) }
end

RSpec.shared_examples_for "a database_cleaner adapter" do
  it { expect(described_class).to respond_to(:available_strategies) }
  it { expect(described_class).to respond_to(:default_strategy) }

  it 'default_strategy should be part of available_strategies' do
    expect(described_class.available_strategies).to include(described_class.default_strategy)
  end
end
