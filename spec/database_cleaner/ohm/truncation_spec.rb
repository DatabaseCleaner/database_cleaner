require 'spec_helper'
require 'support/connection_helpers'
require 'database_cleaner/ohm/truncation'

module DatabaseCleaner
  module Ohm

    class Widget < ::Ohm::Model
      attribute :name
    end

    class Gadget < ::Ohm::Model
      attribute :name
    end

    describe Truncation do
      before(:all) do
        @redis = ::ConnectionHelpers::Redis.build_ohm_connection
      end

      before(:each) do
        @redis.flushdb
      end

      it "should flush the database" do
        truncation.clean
      end

      def truncation(options={})
        truncation = Truncation.new(options)
        truncation.db = ::ConnectionHelpers::Redis.url
        truncation
      end

      def create_widget(attrs={})
        Widget.new({:name => 'some widget'}.merge(attrs)).save
      end

      def create_gadget(attrs={})
        Gadget.new({:name => 'some gadget'}.merge(attrs)).save
      end

      it "truncates all keys by default" do
        create_widget
        create_gadget
        @redis.keys.size.should eq 6
        truncation.clean
        @redis.keys.size.should eq 0
      end

      context "when keys are provided to the :only option" do
        it "only truncates the specified keys" do
          create_widget
          create_gadget
          @redis.keys.size.should eq 6
          truncation(:only => ['*Widget*']).clean
          @redis.keys.size.should eq 3
          @redis.get('DatabaseCleaner::Ohm::Gadget:id').should eq '1'
        end
      end

      context "when keys are provided to the :except option" do
        it "truncates all but the specified keys" do
          create_widget
          create_gadget
          @redis.keys.size.should eq 6
          truncation(:except => ['*Widget*']).clean
          @redis.keys.size.should eq 3
          @redis.get('DatabaseCleaner::Ohm::Widget:id').should eq '1'
        end
      end
    end
  end
end
