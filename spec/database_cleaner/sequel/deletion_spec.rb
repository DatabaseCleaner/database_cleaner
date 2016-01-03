require 'spec_helper'
require 'support/connection_helpers'
require 'database_cleaner/sequel/deletion'
require 'database_cleaner/shared_strategy'
require 'support/sequel/create_databases'

module DatabaseCleaner
  module Sequel
    describe Deletion do
      it_should_behave_like "a generic strategy"
    end

    shared_examples 'a Sequel deletion strategy' do
      let(:deletion) do
        d = Deletion.new
        d.db = db
        d
      end

      context 'when several tables have data' do
        before(:each) do
          db.create_table!(:precious_stones) { primary_key :id }
          db.create_table!(:replaceable_trifles)  { primary_key :id }
          db.create_table!(:worthless_junk)  { primary_key :id }

          db[:precious_stones].insert
          db[:replaceable_trifles].insert
          db[:worthless_junk].insert
        end

        context 'by default' do
          it 'deletes all the tables' do
            d = Deletion.new
            d.db = db
            d.clean

            expect(db[:replaceable_trifles]).to have(0).rows
            expect(db[:worthless_junk]).to have(0).rows
            expect(db[:precious_stones]).to have(0).rows
          end
        end
      end
    end

    supported_databases = %w{mysql postgres}

    supported_databases.each do |db_name|
      describe "Sequel deletion (using a #{db_name} connection)" do
        let(:db) { ::ConnectionHelpers::Sequel.build_connection_for db_name }

        it_behaves_like 'a Sequel deletion strategy'
      end
    end
  end
end
