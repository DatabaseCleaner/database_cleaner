require 'active_record'
require 'database_cleaner/active_record/base'
require 'database_cleaner/spec'

class FakeModel
  def self.connection
    :fake_connection
  end
end

RSpec.describe DatabaseCleaner::ActiveRecord do
  it { is_expected.to respond_to(:available_strategies) }

  describe "config_file_location" do
    after do
      # prevent global state leakage
      DatabaseCleaner::ActiveRecord.config_file_location=nil
      DatabaseCleaner.app_root = nil
    end

    it "should default to \#{DatabaseCleaner.app_root}/config/database.yml" do
      DatabaseCleaner::ActiveRecord.config_file_location = nil
      DatabaseCleaner.app_root = "/path/to"
      expect(DatabaseCleaner::ActiveRecord.config_file_location).to eq '/path/to/config/database.yml'
    end
  end
end

module DatabaseCleaner
  module ActiveRecord
    class ExampleStrategy
      include DatabaseCleaner::ActiveRecord::Base
    end

    RSpec.describe ExampleStrategy do
      let(:config_location) { '/path/to/config/database.yml' }

      around do |example|
        DatabaseCleaner::ActiveRecord.config_file_location = config_location
        example.run
        DatabaseCleaner::ActiveRecord.config_file_location = nil
      end

      it_should_behave_like "a generic strategy"

      describe "db" do
        it "should store my desired db" do
          subject.db = :my_db
          expect(subject.db).to eq :my_db
        end

        it "should default to :default" do
          expect(subject.db).to eq :default
        end
      end

      describe "db=" do
        let(:config_location) { "spec/support/example.database.yml" }

        it "should process erb in the config" do
          subject.db = :my_db
          expect(subject.connection_hash).to eq({ "database" => "one" })
        end

        context 'when config file differs from established ActiveRecord configuration' do
          before do
            allow(::ActiveRecord::Base).to receive(:configurations).and_return({ "my_db" => { "database" => "two"} })
          end

          it 'uses the ActiveRecord configuration' do
            subject.db = :my_db
            expect(subject.connection_hash).to eq({ "database" => "two"})
          end
        end

        context 'when config file agrees with ActiveRecord configuration' do
          before do
            allow(::ActiveRecord::Base).to receive(:configurations).and_return({ "my_db" => { "database" => "one"} })
          end

          it 'uses the config file' do
            subject.db = :my_db
            expect(subject.connection_hash).to eq({ "database" => "one"})
          end
        end

        context 'when ::ActiveRecord::Base.configurations nil' do
          before do
            allow(::ActiveRecord::Base).to receive(:configurations).and_return(nil)
          end

          it 'uses the config file' do
            subject.db = :my_db
            expect(subject.connection_hash).to eq({ "database" => "one"})
          end
        end

        context 'when ::ActiveRecord::Base.configurations empty' do
          before do
            allow(::ActiveRecord::Base).to receive(:configurations).and_return({})
          end

          it 'uses the config file' do
            subject.db = :my_db
            expect(subject.connection_hash).to eq({ "database" => "one"})
          end
        end

        context 'when config file is not available' do
          before do
            allow(File).to receive(:file?).with(config_location).and_return(false)
          end

          it "should skip config" do
            subject.db = :my_db
            expect(subject.connection_hash).not_to be
          end
        end

        it "skips the file when the model is set" do
          subject.db = FakeModel
          expect(subject.connection_hash).not_to be
        end

        it "skips the file when the db is set to :default" do
          # to avoid https://github.com/bmabey/database_cleaner/issues/72
          subject.db = :default
          expect(subject.connection_hash).not_to be
        end
      end

      describe "connection_class" do
        it "should default to ActiveRecord::Base" do
          expect(subject.connection_class).to eq ::ActiveRecord::Base
        end

        context "with database models" do
          context "connection_hash is set" do
            it "reuses the model's connection" do
              subject.connection_hash = {}
              subject.db = FakeModel
              expect(subject.connection_class).to eq FakeModel
            end
          end

          context "connection_hash is not set" do
            it "reuses the model's connection" do
              subject.db = FakeModel
              expect(subject.connection_class).to eq FakeModel
            end
          end
        end

        context "when connection_hash is set" do
          let(:hash) { {} }
          before { subject.connection_hash = hash }

          it "establishes a connection with it" do
            expect(::ActiveRecord::Base).to receive(:establish_connection).with(hash)
            expect(subject.connection_class).to eq ::ActiveRecord::Base
          end
        end
      end
    end
  end
end
