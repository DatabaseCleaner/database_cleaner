require 'mongo_mapper'
require 'database_cleaner/mongo_mapper/truncation'
require File.dirname(__FILE__) + '/mongo_examples'

module DatabaseCleaner
  module MongoMapper

    describe Truncation do

      #doing this in the file root breaks autospec, doing it before(:all) just fails the specs
      before(:all) do
          ::MongoMapper.connection = ::Mongo::Connection.new('127.0.0.1')
          @test_db = 'database_cleaner_specs'
          ::MongoMapper.database = @test_db
      end

      before(:each) do
        ::MongoMapper.connection.drop_database(@test_db)
      end

      def create_widget(attrs={})
        Widget.new({:name => 'some widget'}.merge(attrs)).save!
      end

      def create_gadget(attrs={})
        Gadget.new({:name => 'some gadget'}.merge(attrs)).save!
      end

      it "truncates all collections by default" do
        create_widget
        create_gadget
        expect { Truncation.new.clean }.to change {
          [Widget.count, Gadget.count]
        }.from([1,1]).to([0,0])
      end

      context "when collections are provided to the :only option" do
        it "only truncates the specified collections" do
          create_widget
          create_gadget
          expect { Truncation.new(only: ['widgets']).clean }.to change {
            [Widget.count, Gadget.count]
          }.from([1,1]).to([0,1])
        end
      end

      context "when collections are provided to the :except option" do
        it "truncates all but the specified collections" do
          create_widget
          create_gadget
          expect { Truncation.new(except: ['widgets']).clean }.to change {
            [Widget.count, Gadget.count]
          }.from([1,1]).to([1,0])
        end
      end

    end

  end
end
