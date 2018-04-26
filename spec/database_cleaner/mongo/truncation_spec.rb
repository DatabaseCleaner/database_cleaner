require 'mongo'
require 'database_cleaner/mongo/truncation'
require File.dirname(__FILE__) + '/mongo_examples'

module DatabaseCleaner
  module Mongo

    describe Truncation do
      let(:args) {{}}
      let(:truncation) { described_class.new(args).tap { |t| t.db=@db } }
      #doing this in the file root breaks autospec, doing it before(:all) just fails the specs
      before(:all) do
        @connection = ::Mongo::Connection.new('127.0.0.1')
        @test_db = 'database_cleaner_specs'
        @db = @connection.db(@test_db)
      end

      after(:each) do
        @connection.drop_database(@test_db)
      end

      def create_widget(attrs={})
        MongoTest::Widget.new({:name => 'some widget'}.merge(attrs)).save!
      end

      def create_gadget(attrs={})
        MongoTest::Gadget.new({:name => 'some gadget'}.merge(attrs)).save!
      end

      it "truncates all collections by default" do
        create_widget
        create_gadget
        expect { truncation.clean }.to change {
          [MongoTest::Widget.count, MongoTest::Gadget.count]
        }.from([1,1]).to([0,0])
      end

      context "when collections are provided to the :only option" do
        let(:args) {{:only => ['MongoTest::Widget']}}
        it "only truncates the specified collections" do
          create_widget
          create_gadget
          expect { truncation.clean }.to change {
            [MongoTest::Widget.count, MongoTest::Gadget.count]
          }.from([1,1]).to([0,1])
        end
      end

      context "when collections are provided to the :except option" do
        let(:args) {{:except => ['MongoTest::Widget']}}
        it "truncates all but the specified collections" do
          create_widget
          create_gadget
          expect { truncation.clean }.to change {
            [MongoTest::Widget.count, MongoTest::Gadget.count]
          }.from([1,1]).to([1,0])
        end
      end

    end

  end
end
