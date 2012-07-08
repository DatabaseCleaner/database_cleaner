shared_examples_for "Fast truncation" do
  describe "#truncate_table_with_id_reset" do
    it "responds" do
      adapter.instance_methods.should include('truncate_table_with_id_reset')
    end

    it "should truncate the table" do
      2.times { User.create }

      connection.truncate_table_with_id_reset('users')
      User.count.should == 0
    end

    it "should reset AUTO_INCREMENT index of table" do
      2.times { User.create }
      User.delete_all

      connection.truncate_table_with_id_reset('users')

      User.create.id.should == 1
    end
  end

  describe "#truncate_table_no_id_reset" do
    it "responds" do
      adapter.instance_methods.map(&:to_s).should include('truncate_table_no_id_reset')
    end

    it "should truncate the table" do
      2.times { User.create }

      connection.truncate_table_no_id_reset('users')
      User.count.should == 0
    end

    it "should not reset AUTO_INCREMENT index of table" do
      2.times { User.create }
      User.delete_all

      connection.truncate_table_no_id_reset('users')

      User.create.id.should == 3
    end
  end

  describe "#fast_truncate_tables" do
    it "responds" do
      adapter.instance_methods.should include('fast_truncate_tables')
    end

    it 'should call #truncate_table_with_id_reset on each table if :reset_ids option true was given' do
      connection.should_receive(:truncate_table_with_id_reset).exactly(connection.tables.size).times

      connection.fast_truncate_tables(connection.tables)
    end

    it 'should call #truncate_table_with_id_reset on each table if :reset_ids option false was given' do
      connection.should_receive(:truncate_table_no_id_reset).exactly(connection.tables.size).times

      connection.fast_truncate_tables(connection.tables, :reset_ids => false)
    end
  end
end
