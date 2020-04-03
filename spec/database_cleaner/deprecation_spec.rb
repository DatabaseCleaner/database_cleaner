require "database_cleaner/deprecation"

RSpec.describe DatabaseCleaner do
  describe ".called_externally?" do
    let(:path) { "/home/DatabaseCleaner/database_cleaner/spec/database_cleaner/deprecation_spec.rb" }

    it "returns false if the supplied file is the first file in the backtrace" do
      backtrace = [
        "/home/DatabaseCleaner/database_cleaner/spec/database_cleaner/deprecation_spec.rb:9 in `it'",
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1954:in `load'",
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1954:in `load_spec_file_handling_errors'",
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1496:in `block in load_spec_files'",
      ]
      expect(DatabaseCleaner.called_externally?(path, backtrace)).to eq false
    end

    it "returns true if the supplied file is not the first file in the backtrace" do
      backtrace = [
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1954:in `load'",
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1954:in `load_spec_file_handling_errors'",
        "/home/DatabaseCleaner/lib/rspec/core/configuration.rb:1496:in `block in load_spec_files'",
      ]
      expect(DatabaseCleaner.called_externally?(path, backtrace)).to eq true
    end
  end
end
