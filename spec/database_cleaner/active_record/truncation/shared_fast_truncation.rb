shared_examples_for "an adapter with pre-count truncation" do
  describe "#pre_count_truncate_tables" do
    
    context "with :reset_ids set true" do
      it "truncates the table" do
        2.times { User.create }

        connection.pre_count_truncate_tables(%w[users], :reset_ids => true)
        User.count.should be_zero
      end

      it "resets AUTO_INCREMENT index of table" do
        2.times { User.create }
        User.delete_all

        connection.pre_count_truncate_tables(%w[users]) # true is also the default
        User.create.id.should eq 1
      end
    end

    
    context "with :reset_ids set false" do
      it "truncates the table" do
        2.times { User.create }

        connection.pre_count_truncate_tables(%w[users], :reset_ids => false)
        User.count.should be_zero
      end

      it "does not reset AUTO_INCREMENT index of table" do
        2.times { User.create }
        User.delete_all

        connection.pre_count_truncate_tables(%w[users], :reset_ids => false)

        User.create.id.should eq 3
      end
    end
  end
end
