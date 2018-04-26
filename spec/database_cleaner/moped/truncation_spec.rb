require 'moped'
require 'database_cleaner/moped/truncation'
require File.dirname(__FILE__) + '/moped_examples'

module DatabaseCleaner
  module Moped

    describe Truncation do
      let(:args) {{}}
      let(:truncation) { described_class.new(args) }
      #doing this in the file root breaks autospec, doing it before(:all) just fails the specs
      before(:all) do
        @test_db = 'database_cleaner_specs'
        @session = ::Moped::Session.new(['127.0.0.1:27017'], database: @test_db)
      end

      before(:each) do
        truncation.db = @test_db
      end

      after(:each) do
        @session.drop
        @session.command(getlasterror: 1)
      end

      def create_widget(attrs={})
        MopedTest::Widget.new({:name => 'some widget'}.merge(attrs)).save!
      end

      def create_gadget(attrs={})
        MopedTest::Gadget.new({:name => 'some gadget'}.merge(attrs)).save!
      end

      def create_system(attrs={})
        MopedTest::System.new({:name => 'some system'}.merge(attrs)).save!
      end

      it "truncates all collections by default" do
        create_widget
        create_gadget
        create_system
        expect { truncation.clean }.to change {
          [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
        }.from([1,1,1]).to([0,0,0])
      end

      context "when collections are provided to the :only option" do
        let(:args) {{:only => ['MopedTest::Widget']}}
        it "only truncates the specified collections" do
          create_widget
          create_gadget
          expect { truncation.clean }.to change {
            [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
          }.from([1,1,0]).to([0,1,0])
        end
      end

      context "when collections are provided to the :except option" do
        let(:args) {{:except => ['MopedTest::Widget']}}
        it "truncates all but the specified collections" do
          create_widget
          create_gadget
          expect { truncation.clean }.to change {
            [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
          }.from([1,1,0]).to([1,0,0])
        end
      end

    end

  end
end
