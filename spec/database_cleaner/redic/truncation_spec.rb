require File.dirname(__FILE__) + '/../../spec_helper'
require 'redic'
require 'database_cleaner/redic/truncation'
require 'yaml'


module DatabaseCleaner
  module Redic

    describe Truncation do
      before(:all) do
        config =  YAML::load(File.open("#{File.dirname(__FILE__)}/../../../examples/config/redis.yml"))
      @redic = ::Redic.new config['test']['url']
      end

      before(:each) do
        @redic.call('FLUSHDB')
      end

      it "should flush the database" do
        Truncation.new.clean
      end

      def create_widget(attrs={})
        @redic.call 'SET', 'Widget', 1
      end

      def create_gadget(attrs={})
        @redic.call 'SET', 'Gadget', 1
      end

      it "truncates all keys by default" do
        create_widget
        create_gadget
        @redic.call('KEYS', '*').size.should eq 2
        Truncation.new.clean
        @redic.call('KEYS', '*').size.should eq 0
      end

      context "when keys are provided to the :only option" do
        it "only truncates the specified keys" do
          create_widget
          create_gadget
          @redic.call('KEYS', '*').size.should eq 2
          Truncation.new(:only => ['Widge*']).clean
          @redic.call('KEYS', '*').size.should eq 1
          @redic.call('GET', 'Gadget').should eq '1'
        end
      end

      context "when keys are provided to the :except option" do
        it "truncates all but the specified keys" do
          create_widget
          create_gadget
          @redic.call('KEYS', '*').size.should eq 2
          Truncation.new(:except => ['Widg*']).clean
          @redic.call('KEYS', '*').size.should eq 1
          @redic.call('GET', 'Widget').should eq '1'
        end
      end
    end
  end
end
