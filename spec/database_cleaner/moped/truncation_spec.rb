require 'moped'
require 'database_cleaner/moped/truncation'
require File.dirname(__FILE__) + '/moped_examples'

describe DatabaseCleaner::Moped::Truncation do
  around do |example|
    db_name = 'database_cleaner_specs'
    session = ::Moped::Session.new(['127.0.0.1:27017'], database: db_name)
    subject.db = db_name

    example.run

    session.drop
    session.command(getlasterror: 1)
  end

  before do
    MopedTest::Widget.new(name: 'some widget').save!
    MopedTest::Gadget.new(name: 'some gadget').save!
    MopedTest::System.new(name: 'some system').save!
  end

  context "by default" do
    it "truncates all collections" do
      expect { subject.clean }.to change {
        [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
      }.from([1,1,1]).to([0,0,0])
    end
  end

  context "when collections are provided to the :only option" do
    subject { described_class.new(only: ['MopedTest::Widget']) }

    it "only truncates the specified collections" do
      expect { subject.clean }.to change {
        [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
      }.from([1,1,1]).to([0,1,1])
    end
  end

  context "when collections are provided to the :except option" do
    subject { described_class.new(except: ['MopedTest::Widget']) }

    it "truncates all but the specified collections" do
      expect { subject.clean }.to change {
        [MopedTest::Widget.count, MopedTest::Gadget.count, MopedTest::System.count]
      }.from([1,1,1]).to([1,0,0])
    end
  end
end

