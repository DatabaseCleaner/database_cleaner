require 'redis'
require 'database_cleaner/redis/base'
require 'database_cleaner/spec'

module DatabaseCleaner
  RSpec.describe Redis do
    it { is_expected.to respond_to(:available_strategies) }
  end

  module Redis
    class ExampleStrategy
      include ::DatabaseCleaner::Redis::Base
    end

    RSpec.describe ExampleStrategy do

      it_should_behave_like "a generic strategy"
      it { is_expected.to respond_to(:db) }
      it { is_expected.to respond_to(:db=) }

      context "when passing db" do
        it "should store my describe db" do
          db = 'redis://localhost:6379/2'
          subject.db = 'redis://localhost:6379/2'
          expect(subject.db).to eq db
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

      describe "#url deprecation" do
        it "shows a deprecation warning when called" do
          expect(DatabaseCleaner).to receive(:deprecate)
          expect(subject.url).to eq(subject.db)
        end

        it "doesn't show a deprecation warning when db is used" do
          expect(DatabaseCleaner).to_not receive(:deprecate)
          subject.db
        end
      end
    end
  end
end
