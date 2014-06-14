require File.dirname(__FILE__) + '/../../spec_helper'
require 'ohm'
require 'database_cleaner/ohm/truncation'
require 'yaml'
require 'redic'

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
        config = YAML::load(File.open("#{File.dirname(__FILE__)}/../../../examples/config/redis.yml"))
        ::Ohm.redis =  ::Redic.new config['test']['url']
        @redis = ::Ohm.redis
      end

      before(:each) do
        @redis.call('FLUSHDB')
      end

      it "should flush the database" do
        Truncation.new.clean
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
        @redis.call('KEYS', '*').size.should eq 6
        Truncation.new.clean
        @redis.call('KEYS', '*').size.should eq 0
      end

      context "when keys are provided to the :only option" do
        it "only truncates the specified keys" do
          create_widget
          create_gadget
          @redis.call('KEYS', '*').size.should eq 6
          Truncation.new(:only => ['*Widget*']).clean
          @redis.call('KEYS', '*').size.should eq 3
          @redis.call('GET', 'DatabaseCleaner::Ohm::Gadget:id').should eq '1'
        end
      end

      context "when keys are provided to the :except option" do
        it "truncates all but the specified keys" do
          create_widget
          create_gadget
          @redis.call('KEYS', '*').size.should eq 6
          Truncation.new(:except => ['*Widget*']).clean
          @redis.call('KEYS', '*').size.should eq 3
          @redis.call('GET', 'DatabaseCleaner::Ohm::Widget:id').should eq '1'
        end
      end
    end
  end
end
