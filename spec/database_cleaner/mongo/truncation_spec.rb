require File.dirname(__FILE__) + '/../../spec_helper'
require 'mongo'
require 'database_cleaner/mongo/truncation'
require File.dirname(__FILE__) + '/mongo_examples'

module DatabaseCleaner
  module Mongo

    describe Truncation do

      #doing this in the file root breaks autospec, doing it before(:all) just fails the specs
      before(:all) do
        @connection = ::Mongo::Connection.new('127.0.0.1')
        @test_db = 'database_cleaner_specs'
        @connection.db(@test_db)
      end

      after(:each) do
        @connection.drop_database(@test_db)
      end

      def ensure_counts(expected_counts)
        # I had to add this sanity_check garbage because I was getting non-determinisc results from mongo at times..
        # very odd and disconcerting...
        expected_counts.each do |model_class, expected_count|
          model_class.count.should equal(expected_count), "#{model_class} expected to have a count of #{expected_count} but was #{model_class.count}"
        end
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
        ensure_counts(MongoTest::Widget => 1, MongoTest::Gadget => 1)
        Truncation.new.clean
        ensure_counts(MongoTest::Widget => 0, MongoTest::Gadget => 0)
      end

      context "when collections are provided to the :only option" do
        it "only truncates the specified collections" do
          create_widget
          create_gadget
          ensure_counts(MongoTest::Widget => 1, MongoTest::Gadget => 1)
          Truncation.new(:only => ['widgets']).clean
          ensure_counts(MongoTest::Widget => 0, MongoTest::Gadget => 1)
        end
      end

      context "when collections are provided to the :except option" do
        it "truncates all but the specified collections" do
          create_widget
          create_gadget
          ensure_counts(MongoTest::Widget => 1, MongoTest::Gadget => 1)
          Truncation.new(:except => ['widgets']).clean
          ensure_counts(MongoTest::Widget => 1, MongoTest::Gadget => 0)
        end
      end

    end

  end
end
