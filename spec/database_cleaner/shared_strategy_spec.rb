shared_examples_for "database cleaner strategy" do
  it { should respond_to :db  }
  it { should respond_to :db= }
  it { should respond_to :connection_klass }
end