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

shared_examples_for "an adapter with random-ids truncation" do
  describe "#random_ids_truncate_tables" do

    before do
      allow(connection).to receive(:rand).with(1000).and_return 123 # Forcing rand() to always return 123
    end

    context "with :random_ids set true" do
      before do
        2.times { User.create }
      end

      it "truncates the table" do
        connection.random_ids_truncate_tables(%w[users], :random_ids => true)
        User.count.should be_zero
      end

      it "randomly set AUTO_INCREMENT index of table" do
        User.delete_all

        connection.random_ids_truncate_tables(%w[users]) # true is also the default
        User.create.id.should eq 1230
      end
    end


    context "with :reset_ids as an array" do
      before do
        2.times { User.create }
        2.times { ToDo.create }
      end

      it "truncates all tables" do
        connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => %w[users])
        User.count.should be_zero
        ToDo.count.should be_zero
      end

      it "only randomize AUTO_INCREMENT index of selected table" do
        User.delete_all
        ToDo.delete_all

        connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => %w[users])
        User.create.id.should eq 1230
        ToDo.create.key.should eq 1
      end
    end


    context "with :reset_ids as a hash" do
      before do
        2.times { User.create }
        2.times { ToDo.create }
      end

      context "truncates all tables" do
        it "given symbols" do
          connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => {to_dos: :key})
          User.count.should be_zero
          ToDo.count.should be_zero
        end

        it "given strings" do
          connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => {'to_dos' => 'key'})
          User.count.should be_zero
          ToDo.count.should be_zero
        end
      end

      context "only randomize AUTO_INCREMENT index of listed table" do
        before do
          User.delete_all
          ToDo.delete_all
        end

        it "given symbols" do
          connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => {to_dos: :key})
          User.create.id.should eq 1
          ToDo.create.key.should eq 1230
        end

        it "given strings" do
          connection.random_ids_truncate_tables(%w[users to_dos], :random_ids => {'to_dos' => 'key'})
          User.create.id.should eq 1
          ToDo.create.key.should eq 1230
        end
      end
    end


    context "with :reset_ids set false" do
      it "truncates the table" do
        2.times { User.create }

        connection.random_ids_truncate_tables(%w[users], :random_ids => false)
        User.count.should be_zero
      end

      it "does not randomize AUTO_INCREMENT index of table" do
        2.times { User.create }
        User.delete_all

        connection.random_ids_truncate_tables(%w[users], :random_ids => false)

        User.create.id.should eq 1
      end
    end
  end
end
