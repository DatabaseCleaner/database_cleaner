require 'spec_helper'
require 'active_record'
require 'support/active_record/mysql2_setup'
require 'database_cleaner/active_record/deletion'

module ActiveRecord
  module AbstractMysqlAdapter
    describe do
      before(:all) { active_record_mysql2_setup }

      let(:connection) { active_record_mysql2_connection }

      subject { DatabaseCleaner::ActiveRecord::Deletion.new }

      describe "#delete_table" do
        it "should delete the table" do
          2.times { User.create }

          allow(subject).to receive(:tables_with_new_rows).and_return(["users"])

          subject.clean

          User.count.should eq 0
        end
      end
    end
  end
end
