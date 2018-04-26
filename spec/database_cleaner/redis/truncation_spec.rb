require 'redis'
require 'database_cleaner/redis/truncation'


module DatabaseCleaner
  module Redis

    describe Truncation do
      before(:all) do
        config = YAML::load(File.open("#{File.dirname(__FILE__)}/../../../examples/config/redis.yml"))
      @redis = ::Redis.new :url => config['test']['url']
      end

      before(:each) do
        @redis.flushdb
      end

      it "should flush the database" do
        Truncation.new.clean
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
        expect(@redis.keys.size).to eq 2
        Truncation.new.clean
        expect(@redis.keys.size).to eq 0
      end

      context "when keys are provided to the :only option" do
        it "only truncates the specified keys" do
          create_widget
          create_gadget
          expect(@redis.keys.size).to eq 2
          Truncation.new(:only => ['Widge*']).clean
          expect(@redis.keys.size).to eq 1
          expect(@redis.get('Gadget')).to eq '1'
        end
      end

      context "when keys are provided to the :except option" do
        it "truncates all but the specified keys" do
          create_widget
          create_gadget
          expect(@redis.keys.size).to eq 2
          Truncation.new(:except => ['Widg*']).clean
          expect(@redis.keys.size).to eq 1
          expect(@redis.get('Widget')).to eq '1'
        end
      end
    end
  end
end

