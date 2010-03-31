require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'


describe DatabaseCleaner do

  describe ActiveRecord do
    describe "connections" do
      it "should return an array of classes containing ActiveRecord::Base by default" do
        ::DatabaseCleaner::ActiveRecord.connection_klasses.should == [::ActiveRecord::Base]
      end
      it "should merge in an array of classes to get connections from" do
        model = mock("model")
        ::DatabaseCleaner::ActiveRecord.connection_klasses = [model]
        ::DatabaseCleaner::ActiveRecord.connection_klasses.should include model
        ::DatabaseCleaner::ActiveRecord.connection_klasses.should include ::ActiveRecord::Base
      end
    end    
  end
  
  context "orm specification" do

    it "should not accept unrecognised orms" do
      lambda { ::DatabaseCleaner[nil] }.should raise_error ::DatabaseCleaner::NoORMDetected
    end
    
    it "should accept :active_record" do
      cleaner = ::DatabaseCleaner[:active_record]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :active_record
    end
    
    it "should accept :data_mapper" do
      cleaner = ::DatabaseCleaner[:data_mapper]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :data_mapper
    end
    
    it "should accept :mongo_mapper" do
      cleaner = ::DatabaseCleaner[:mongo_mapper]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :mongo_mapper
    end
    
    it "should accept :couch_potato" do
      cleaner = ::DatabaseCleaner[:couch_potato]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :couch_potato
    end
  end
  
  context "class methods" do
    it "should have array of connections (orm agnostic)" do
      ::DatabaseCleaner.connections.should respond_to(:each)
    end
    
    it "should give me a default (autodetection) databasecleaner by default" do
      ::DatabaseCleaner.connections.should have (1).items
      ::DatabaseCleaner.connections.first.should be_a ::DatabaseCleaner::Base
      ::DatabaseCleaner.connections.first.auto_detected.should be_true
    end
  end
  
  context "instance methods" do
    it "should default to autodetect upon initalisation" do
      cleaner = ::DatabaseCleaner::Base.new
      cleaner.auto_detected.should == true
    end
    
     context "autodetect" do
       before(:all) do
         Temp_AR = ActiveRecord if defined?(::ActiveRecord) and not defined?(Temp_AR)
         Temp_DM = DataMapper   if defined?(::DataMapper)   and not defined?(Temp_DM)
         Temp_MM = MongoMapper  if defined?(::MongoMapper)  and not defined?(Temp_MM)
         Temp_CP = CouchPotato  if defined?(::CouchPotato)  and not defined?(Temp_CP)
       end
       
       before(:each) do
         # Remove ORM consts for these tests
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
       end
       

       it "should raise an error when no ORM is detected" do
         running { DatabaseCleaner::Base.new(:autodetect)  }.should raise_error(DatabaseCleaner::NoORMDetected)
       end
       
       it "should detect ActiveRecord first" do
         Object.const_set('ActiveRecord','Actively mocking records.')
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')
         
         cleaner = DatabaseCleaner::Base.new :autodetect
         cleaner.orm.should == :active_record
       end
       it "should detect DataMapper second" do
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')

          cleaner = DatabaseCleaner::Base.new :autodetect
          cleaner.orm.should == :data_mapper
       end
       it "should detect MongoMapper third" do
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('CouchPotato', 'Couching mock potatos')

          cleaner = DatabaseCleaner::Base.new :autodetect
          cleaner.orm.should == :mongo_mapper
       end
       
       it "should detect CouchPotato last" do
         Object.const_set('CouchPotato', 'Couching mock potatos')

          cleaner = DatabaseCleaner::Base.new :autodetect
          cleaner.orm.should == :couch_potato
       end
       
       after(:all) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
         
         # Restore ORMs
         ActiveRecord = Temp_AR if defined? Temp_AR
         DataMapper   = Temp_DM if defined? Temp_DM
         MongoMapper  = Temp_MM if defined? Temp_MM
         CouchPotato  = Temp_CP if defined? Temp_CP
       end
     end
  end

  context "single orm single connection" do
    let (:connection) { ::DatabaseCleaner.connections.first }
    it "should proxy strategy=" do
      stratagum = mock("stratagum")
      connection.should_receive(:strategy=).with(stratagum)
      ::DatabaseCleaner.strategy = stratagum
    end
    
    it "should proxy orm=" do
      orm = mock("orm")
      connection.should_receive(:orm=).with(orm)
      ::DatabaseCleaner.orm = orm
    end
    
    it "should proxy start" do
      connection.should_receive(:start)
      ::DatabaseCleaner.start
    end
    
    it "should proxy clean" do
      connection.should_receive(:clean)
      ::DatabaseCleaner.clean
    end
    
    it "should proxy clean_with" do
      stratagem = mock("stratgem")
      connection.should_receive(:clean_with).with(stratagem)
      ::DatabaseCleaner.clean_with stratagem
    end
  end
  
  context "multiple orms single connection per orm" do
    context "proxy methods" do
      let(:active_record) { mock("active_mock") }
      let(:data_mapper)   { mock("data_mock")   }
    
      before(:each) do
        ::DatabaseCleaner.stub!(:connections).and_return([active_record,data_mapper])
      end
    
      it "should proxy start to all connections" do
        active_record.should_receive(:start)
        data_mapper.should_receive(:start)
        
        ::DatabaseCleaner.start
      end
      
      it "should proxy clean to all connections" do
        active_record.should_receive(:clean)
        data_mapper.should_receive(:clean)
        
        ::DatabaseCleaner.clean
      end
      
      it "should proxy clean_with to all connections" do
        stratagem = mock("stratgem")
        active_record.should_receive(:clean_with).with(stratagem)
        data_mapper.should_receive(:clean_with).with(stratagem)
        
        ::DatabaseCleaner.clean_with stratagem
      end
    end
    context "more contentious proxy methods" do
      it "should proxy orm to all connections and remove duplicate connections" do
        
         ::DatabaseCleaner.orm = :active_record
      end
    end
  end
    
  describe ::DatabaseCleaner::Base do
    
    let(:strategy) { mock("stratagum") }
    
    context "active record" do 
      let(:cleaner)  { ::DatabaseCleaner::Base.new(:active_record) }
      
      before(:each) do
        ::DatabaseCleaner::ActiveRecord::Transaction.stub!(:new).and_return(strategy)
        #Object.const_set('ActiveRecord', "just mocking out the constant here...") unless defined?(::ActiveRecord)
        cleaner.strategy = nil
      end
  
      describe ".create_strategy" do
        it "should initialize and return the appropriate strategy" do
          DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
          result = cleaner.create_strategy(:transaction, {'options' => 'hash'})
          result.should == strategy
        end
      end

      describe ".clean_with" do
        it "should initialize the appropirate strategy and clean with it" do
          DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
          strategy.should_receive(:clean)
          cleaner.clean_with(:transaction, 'options' => 'hash')
        end
      end

      describe ".strategy=" do
        it "should initialize the appropirate strategy for active record" do
          DatabaseCleaner::ActiveRecord::Transaction.should_receive(:new).with('options' => 'hash')
          cleaner.strategy = :transaction, {'options' => 'hash'}
        end
        
        it "should allow any object to be set as the strategy" do
          mock_strategy = mock('strategy')
          running { DatabaseCleaner.strategy = mock_strategy }.should_not raise_error
        end
        
        it "should raise an error when the specified strategy is not found" do
          running { DatabaseCleaner.strategy = :foo }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
        end
        
        it "should raise an error when multiple args is passed in and the first is not a symbol" do
          running { DatabaseCleaner.strategy=Object.new, {:foo => 'bar'} }.should raise_error(ArgumentError)
        end
      end
      
      %w[start clean].each do |strategy_method|
        describe ".#{strategy_method}" do
          it "should be delgated to the strategy set with strategy=" do
            cleaner.strategy = :transaction

            strategy.should_receive(strategy_method)

            cleaner.send(strategy_method)
          end

          it "should raise en error when no strategy has been set" do
            running { cleaner.send(strategy_method) }.should raise_error(DatabaseCleaner::NoStrategySetError)
          end
        end
      end
    end

    context "data mapper" do
      let(:cleaner)  { ::DatabaseCleaner::Base.new(:data_mapper) }
      
      before(:each) do
        ::DatabaseCleaner::DataMapper::Transaction.stub!(:new).and_return(strategy)
        #Object.const_set('ActiveRecord', "just mocking out the constant here...") unless defined?(::ActiveRecord)
        cleaner.strategy = nil
      end
  
      describe ".create_strategy" do
        it "should initialize and return the appropirate strategy" do
          DatabaseCleaner::DataMapper::Transaction.should_receive(:new)
          result = cleaner.create_strategy(:transaction)
          result.should == strategy
        end
      end

      describe ".clean_with" do
        it "should initialize the appropirate strategy and clean with it" do
          DatabaseCleaner::DataMapper::Transaction.should_receive(:new)
          strategy.should_receive(:clean)
          cleaner.clean_with(:transaction)
        end
      end
      
      describe ".strategy=" do
        it "should initalize the appropriate strategy for data mapper" do
          DatabaseCleaner::DataMapper::Transaction.should_receive(:new).with(no_args)
          cleaner.strategy = :transaction
        end
        
        it "should allow any object to be set as the strategy" do
          mock_strategy = mock('strategy')
          running { cleaner.strategy = mock_strategy }.should_not raise_error
        end
        
        it "should raise an error when the specified strategy is not found" do
          running { cleaner.strategy = :foo }.should raise_error(DatabaseCleaner::UnknownStrategySpecified)
        end
        
        it "should raise an error when multiple args is passed in and the first is not a symbol" do
          running { cleaner.strategy=Object.new, {:foo => 'bar'} }.should raise_error(ArgumentError)
        end
      end
      
      %w[start clean].each do |strategy_method|
        describe ".#{strategy_method}" do
          it "should be delgated to the strategy set with strategy=" do
            cleaner.strategy = :transaction

            strategy.should_receive(strategy_method)

            cleaner.send(strategy_method)
          end

          it "should raise en error when no strategy has been set" do
            running { cleaner.send(strategy_method) }.should raise_error(DatabaseCleaner::NoStrategySetError)
          end
        end
      end
    end

      # it "should raise an error when no ORM is detected" do
      #   Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
      #   Object.send(:remove_const, 'DataMapper') if defined?(::DataMapper)
      #   Object.send(:remove_const, 'CouchPotato') if defined?(::CouchPotato)
      # 
      #   running { DatabaseCleaner.strategy = :transaction }.should raise_error(DatabaseCleaner::NoORMDetected)
      # end

      # it "should use the strategy version of the ORM specified with #orm=" do
      #   DatabaseCleaner.orm = 'data_mapper'
      #   DatabaseCleaner::DataMapper::Transaction.should_receive(:new)
      # 
      #   DatabaseCleaner.strategy = :transaction
      # end

  end 
end
