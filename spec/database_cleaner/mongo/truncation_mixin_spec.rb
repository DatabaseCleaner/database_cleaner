require "spec_helper"
require "database_cleaner/mongo/truncation_mixin"

describe DatabaseCleaner::Mongo::TruncationMixin do
  let(:klass) do
    Class.new do
      include DatabaseCleaner::Mongo::TruncationMixin

      def initialize(database:)
        @tables_to_exclude = []
        @database = database
      end

      def database
        @database
      end
    end
  end

  describe "#clean" do
    it "calls 'remove' method for mongo versions < 2.0" do
      stub_const("::Mongo::VERSION", "1.5.1")
      collection = double(name: "foo")
      allow(collection).to receive(:remove)
      database = double(collections: [collection])

      klass.new(database: database).clean

      expect(collection).to have_received(:remove)
    end

    it "calls 'delete_many' method for mongo versions >= 2.0" do
      stub_const("::Mongo::VERSION", "2.0.0")
      collection = double(name: "foo")
      allow(collection).to receive(:delete_many)
      database = double(collections: [collection])

      klass.new(database: database).clean

      expect(collection).to have_received(:delete_many)
    end
  end
end
