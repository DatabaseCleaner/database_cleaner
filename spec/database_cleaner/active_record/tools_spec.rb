require 'spec_helper'
require 'database_cleaner/active_record/tools'

module DatabaseCleaner
  module ActiveRecord
    class ExampleTools
      include ::DatabaseCleaner::ActiveRecord::Tools
    end

    describe ExampleTools do
      let(:tools) { ExampleTools.new }

      describe "filter_tables_from_ids_param" do
        let(:tables) { %w[table1 table2 table3] }

        it "from a true class" do
          expect(tools.send :_filter_tables_from_ids_param, tables, true).to eq(%w[table1 table2 table3])
        end

        it "from an array" do
          expect(tools.send :_filter_tables_from_ids_param, tables, %w[table1 table3]).to eq(%w[table1 table3])
        end

        it "from a hash" do
          expect(tools.send :_filter_tables_from_ids_param, tables, table2: 'id', 'table3' => 'key').to eq(%w[table2 table3])
        end

        it "from something else" do
          expect(tools.send :_filter_tables_from_ids_param, tables, false).to eq([])
          expect(tools.send :_filter_tables_from_ids_param, tables, "wrong").to eq([])
          expect(tools.send :_filter_tables_from_ids_param, tables, :error).to eq([])
        end
      end
    end
  end
end