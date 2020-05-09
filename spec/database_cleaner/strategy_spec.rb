require "database_cleaner/strategy"

RSpec.describe DatabaseCleaner::Strategy do
  describe "default implementation" do
    it "does not provide a default implementation for #clean" do
      expect { described_class.new.clean }.to raise_exception(NotImplementedError)
    end

    it "rejects options" do
      expect { described_class.new(only: %w[a b c]) }.to \
        raise_exception(ArgumentError, "No options are available for the Strategy strategy.")
    end
  end
end
