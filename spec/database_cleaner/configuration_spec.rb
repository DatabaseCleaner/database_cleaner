require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'

module DatabaseCleaner
  class << self
    def reset
      @connections = nil
    end
  end
end

describe DatabaseCleaner do  
  before (:each) { ::DatabaseCleaner.reset }
  
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
      ::DatabaseCleaner.connections.size.should == 1
    end
    
    it "should accept :data_mapper" do
      cleaner = ::DatabaseCleaner[:data_mapper]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :data_mapper
      ::DatabaseCleaner.connections.size.should == 1
    end
    
    it "should accept :mongo_mapper" do
      cleaner = ::DatabaseCleaner[:mongo_mapper]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :mongo_mapper
      ::DatabaseCleaner.connections.size.should == 1
    end
    
    it "should accept :couch_potato" do
      cleaner = ::DatabaseCleaner[:couch_potato]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :couch_potato
      ::DatabaseCleaner.connections.size.should == 1
    end
    
    it "should accept multiple orm's" do
      ::DatabaseCleaner[:couch_potato]
      ::DatabaseCleaner[:data_mapper]
      ::DatabaseCleaner.connections.size.should == 2
      ::DatabaseCleaner.connections[0].orm.should == :couch_potato
      ::DatabaseCleaner.connections[1].orm.should == :data_mapper
    end
  end
  
  context "connection/db specification" do
    it "should accept a connection parameter and store it" do
      cleaner = ::DatabaseCleaner[:active_record, {:connection => :first_connection}]
      cleaner.should be_a ::DatabaseCleaner::Base
      cleaner.orm.should == :active_record
      cleaner.db.should == :first_connection
    end
    it "should accept multiple connections for a single orm" do
      ::DatabaseCleaner[:data_mapper,{:connection => :first_db}]
      ::DatabaseCleaner[:data_mapper,{:connection => :second_db}]
      ::DatabaseCleaner.connections.size.should == 2
      ::DatabaseCleaner.connections[0].orm.should == :data_mapper
      ::DatabaseCleaner.connections[0].db.should  == :first_db
      ::DatabaseCleaner.connections[1].orm.should == :data_mapper
      ::DatabaseCleaner.connections[1].db.should  == :second_db
    end
    it "should accept multiple connections and multiple orms" do
      ::DatabaseCleaner[:data_mapper,  {:connection => :first_db} ]
      ::DatabaseCleaner[:active_record,{:connection => :second_db}]
      ::DatabaseCleaner[:active_record,{:connection => :first_db} ]
      ::DatabaseCleaner[:data_mapper,  {:connection => :second_db}]
      
      ::DatabaseCleaner.connections.size.should == 4
      
      ::DatabaseCleaner.connections[0].orm.should == :data_mapper
      ::DatabaseCleaner.connections[0].db.should  == :first_db
      
      ::DatabaseCleaner.connections[1].orm.should == :active_record
      ::DatabaseCleaner.connections[1].db.should  == :second_db
      
      ::DatabaseCleaner.connections[2].orm.should == :active_record
      ::DatabaseCleaner.connections[2].db.should  == :first_db
      
      ::DatabaseCleaner.connections[3].orm.should == :data_mapper
      ::DatabaseCleaner.connections[3].db.should  == :second_db
      
    end
  end
  
  context "class methods" do
    it "should have array of connections (orm agnostic)" do
      ::DatabaseCleaner.connections.should respond_to(:each)
    end
    
    it "should give me a default (autodetection) databasecleaner by default" do
      cleaner = mock("cleaner").as_null_object
      ::DatabaseCleaner::Base.should_receive(:new).with().and_return(cleaner)
      
      ::DatabaseCleaner.connections.should have(1).items
      ::DatabaseCleaner.connections.first.should == cleaner
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
  
  context "multiple connections" do
    
    #these are relativly simple, all we need to do is make sure all connections are cleaned/started/cleaned_with appropriatly.
    context "simple proxy methods" do
      
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
    
    # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could 
    # plausably want to force orm/strategy change on two sets of orm that differ only on db
    context "multiple orm proxy methods" do
      let(:active_record_1) { mock("active_mock_on_db_one") }
      let(:active_record_2) { mock("active_mock_on_db_two") }
      let(:data_mapper_1)   { mock("data_mock_on_db_one") }  
      
      it "should proxy orm to all connections and remove duplicate connections" do
        pending
      end
      it "should proxy strategy to all connections and remove duplicate connections"
      
    end
  end

  describe "remove_duplicates" do
    it "should remove duplicates if they are identical" do
      ::DatabaseCleaner[:active_record, {:connection => :one}].strategy = :truncation
      ::DatabaseCleaner[:active_record, {:connection => :one}].strategy = :truncation
      ::DatabaseCleaner[:active_record, {:connection => :one}].strategy = :truncation
      ::DatabaseCleaner.connections.size.should == 3
      ::DatabaseCleaner.remove_duplicates
      ::DatabaseCleaner.connections.size.should == 1
    end
  end
end
