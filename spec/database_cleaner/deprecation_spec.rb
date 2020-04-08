require "database_cleaner/deprecation"

RSpec.describe DatabaseCleaner do
  describe ".called_externally?" do
    context "on a posix filesystem" do
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

    context "on a windows filesystem" do
      let(:path) { "C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/database_cleaner-1.99.0/lib/database_cleaner/base.rb" }

      it "returns false if the supplied file is the first file in the backtrace" do
        backtrace = [
          "C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/database_cleaner-1.99.0/lib/database_cleaner/base.rb:34:in `strategy='",
          "C:/Ruby25-x64/database_cleaner/spec/database_cleaner/deprecation_spec.rb:9 in `it'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1954:in `load'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1954:in `load_spec_file_handling_errors'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1496:in `block in load_spec_files'",
        ]
        expect(DatabaseCleaner.called_externally?(path, backtrace)).to eq false
      end

      it "returns true if the supplied file is not the first file in the backtrace" do
        backtrace = [
          "C:/Ruby25-x64/database_cleaner/spec/database_cleaner/deprecation_spec.rb:9 in `it'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1954:in `load'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1954:in `load_spec_file_handling_errors'",
          "C:/Ruby25-x64/lib/rspec/core/configuration.rb:1496:in `block in load_spec_files'",
        ]
        expect(DatabaseCleaner.called_externally?(path, backtrace)).to eq true
      end
    end
  end
end
