require 'redis'
require 'database_cleaner/redis/base'
require 'database_cleaner/spec'

module DatabaseCleaner
  RSpec.describe Redis do
    it { is_expected.to respond_to(:available_strategies) }

    it "has a default_strategy of truncation" do
      expect(described_class.default_strategy).to eq(:truncation)
    end
  end

  module Redis
    class ExampleStrategy
      include ::DatabaseCleaner::Redis::Base
    end

    RSpec.describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { is_expected.to respond_to(:db) }
      it { is_expected.to respond_to(:db=) }

      context "when passing url" do
        it "should store my describe db" do
          url = 'redis://localhost:6379/2'
          subject.db = 'redis://localhost:6379/2'
          expect(subject.db).to eq url
        end
      end

      context "when passing connection" do
        it "should store my describe db" do
          connection = ::Redis.new :url => 'redis://localhost:6379/2'
          subject.db = connection
          expect(subject.db).to eq connection
        end
      end

      it "should default to :default" do
        expect(subject.db).to eq :default
      end
    end
  end
end
