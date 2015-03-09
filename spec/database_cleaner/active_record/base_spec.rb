require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/base'
require 'database_cleaner/shared_strategy'

class FakeModel
  def self.connection
    :fake_connection
  end
end

module DatabaseCleaner
  describe ActiveRecord do
    it { should respond_to(:available_strategies) }

    describe "config_file_location" do
      subject { ActiveRecord.config_file_location }

      it "should default to DatabaseCleaner.root / config / database.yml" do
        ActiveRecord.config_file_location=nil
        DatabaseCleaner.should_receive(:app_root).and_return("/path/to")
        subject.should eq '/path/to/config/database.yml'
      end
    end

  end

  module ActiveRecord
    class ExampleStrategy
      include ::DatabaseCleaner::ActiveRecord::Base
    end

    describe ExampleStrategy do
      let :config_location do
        '/path/to/config/database.yml'
      end

      before { ::DatabaseCleaner::ActiveRecord.stub(:config_file_location).and_return(config_location) }

      it_should_behave_like "a generic strategy"

      describe "db" do

        it "should store my desired db" do
          subject.stub(:load_config)

          subject.db = :my_db
          subject.db.should eq :my_db
        end

        it "should default to :default" do
          subject.db.should eq :default
        end

        it "should load_config when I set db" do
          subject.should_receive(:load_config)
          subject.db = :my_db
        end
      end

      describe "load_config" do

        before do
          subject.db = :my_db
          yaml       = <<-Y
my_db:
  database: <%= "ONE".downcase %>
          Y
          File.stub(:file?).with(config_location).and_return(true)
          IO.stub(:read).with(config_location).and_return(yaml)
        end

        it "should parse the config" do
          YAML.should_receive(:load).and_return({ :nil => nil })
          subject.load_config
        end

        it "should process erb in the config" do
          transformed = <<-Y
my_db:
  database: one
          Y
          YAML.should_receive(:load).with(transformed).and_return({ "my_db" => { "database" => "one" } })
          subject.load_config
        end

        context 'use ActiveRecord::Base.configuration' do
          it 'when config file different with it' do
            ::ActiveRecord::Base.stub(:configurations).and_return({ "my_db" =>{ "database" => "two"} })
            subject.load_config
            subject.connection_hash.should eq({ "database" => "two"})
          end
        end

        context 'use config file' do
          it 'when config file same with it' do
            ::ActiveRecord::Base.stub(:configurations).and_return({ "my_db" =>{ "database" => "one"} })
            subject.load_config
            subject.connection_hash.should eq({ "database" => "one"})
          end

          it 'when ::ActiveRecord::Base.configurations nil' do
            ::ActiveRecord::Base.stub(:configurations).and_return(nil)
            subject.load_config
            subject.connection_hash.should eq({ "database" => "one"})
          end

          it 'when ::ActiveRecord::Base.configurations empty' do
            ::ActiveRecord::Base.stub(:configurations).and_return({})
            subject.load_config
            subject.connection_hash.should eq({ "database" => "one"})
          end
        end

        it "should store the relevant config in connection_hash" do
          subject.load_config
          subject.connection_hash.should eq( "database" => "one" )
        end

        it "should skip config if config file is not available" do
          File.should_receive(:file?).with(config_location).and_return(false)
          subject.load_config
          subject.connection_hash.should_not be
        end

        it "skips the file when the model is set" do
          subject.db = FakeModel
          YAML.should_not_receive(:load)
          subject.load_config
          subject.connection_hash.should_not be
        end

        it "skips the file when the db is set to :default" do
          # to avoid https://github.com/bmabey/database_cleaner/issues/72
          subject.db = :default
          YAML.should_not_receive(:load)
          subject.load_config
          subject.connection_hash.should_not be
        end

      end

      describe "connection_hash" do
        it "should store connection_hash" do
          subject.connection_hash = { :key => "value" }
          subject.connection_hash.should eq( :key => "value" )
        end
      end

      describe "connection_class" do
        it { expect { subject.connection_class }.to_not raise_error }
        it "should default to ActiveRecord::Base" do
          subject.connection_class.should eq ::ActiveRecord::Base
        end

        context "with database models" do
          context "connection_hash is set" do
            it "allows for database models to be passed in" do
              subject.db = FakeModel
              subject.connection_hash = { }
              subject.load_config
              subject.connection_class.should eq FakeModel
            end
          end

          context "connection_hash is not set" do
            it "allows for database models to be passed in" do
              subject.db = FakeModel
              subject.connection_class.should eq FakeModel
            end
          end
        end

        context "when connection_hash is set" do
          let(:hash) { double("hash") }
          before { ::ActiveRecord::Base.stub(:respond_to?).and_return(false) }
          before { subject.stub(:connection_hash).and_return(hash) }

          it "establish a connection using ActiveRecord::Base" do
            ::ActiveRecord::Base.should_receive(:establish_connection).with(hash)

            subject.connection_class
          end
        end
      end
    end
  end
end
