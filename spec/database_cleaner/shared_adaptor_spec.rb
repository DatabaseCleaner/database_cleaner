shared_examples_for "database cleaner adaptor" do
  it { should respond_to :db  }
  it { should respond_to :db= }
  it { should respond_to :connection_klass }
end