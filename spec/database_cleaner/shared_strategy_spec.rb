shared_examples_for "a generic strategy" do
  it { should respond_to(:db)  }
end

shared_examples_for "a strategy with configurable db" do
  it "stores the desired db" do
    subject.db = :my_db
    subject.db.should == :my_db
  end

  it "defaults #db to :unspecified" do
    subject.db.should == :unspecified
  end
end


shared_examples_for "a generic truncation strategy" do
  it { should respond_to(:start) }
  it { should respond_to(:clean) }
end

shared_examples_for "a generic transaction strategy" do
  it { should respond_to(:start) }
  it { should respond_to(:clean) }
end
