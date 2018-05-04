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
