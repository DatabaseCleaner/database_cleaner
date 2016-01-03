require 'spec_helper'
require 'support/connection_helpers'
require 'database_cleaner/redis/truncation'


module DatabaseCleaner
  module Redis

    describe Truncation do
      before(:all) do
        @redis = ::ConnectionHelpers::Redis.build_connection
      end

      before(:each) do
        @redis.flushdb
      end

      it "should flush the database" do
        truncation.clean
      end

      def truncation(options={})
        truncation = Truncation.new options
        truncation.db = ::ConnectionHelpers::Redis.url
        truncation
      end

      def create_widget(attrs={})
        @redis.set 'Widget', 1
      end

      def create_gadget(attrs={})
        @redis.set 'Gadget', 1
      end

      it "truncates all keys by default" do
        create_widget
        create_gadget
        @redis.keys.size.should eq 2
        truncation.clean
        @redis.keys.size.should eq 0
      end

      context "when keys are provided to the :only option" do
        it "only truncates the specified keys" do
          create_widget
          create_gadget
          @redis.keys.size.should eq 2
          truncation(:only => ['Widge*']).clean
          @redis.keys.size.should eq 1
          @redis.get('Gadget').should eq '1'
        end
      end

      context "when keys are provided to the :except option" do
        it "truncates all but the specified keys" do
          create_widget
          create_gadget
          @redis.keys.size.should eq 2
          truncation(:except => ['Widg*']).clean
          @redis.keys.size.should eq 1
          @redis.get('Widget').should eq '1'
        end
      end
    end
  end
end

