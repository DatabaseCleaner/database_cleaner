require 'spec_helper'
module ::DatabaseCleaner::Generic
  describe Adaptor do 
    it { should respond_to :db  }
    it { should respond_to :db= }
    it { should respond_to :connection_klass }
  end
end