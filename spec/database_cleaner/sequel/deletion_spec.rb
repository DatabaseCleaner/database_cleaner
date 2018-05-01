require 'database_cleaner/sequel/deletion'
require 'database_cleaner/shared_strategy'
require 'sequel'
require 'support/sequel/sequel_setup'
# XXX: use ActiveRecord's db_config (`db/config.yml`) for CI/dev convenience
require 'support/active_record/database_setup'

module DatabaseCleaner
  module Sequel
    RSpec.describe Deletion do
      it_should_behave_like "a generic strategy"
    end

    RSpec.shared_examples 'a Sequel deletion strategy' do
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

            expect(db[:replaceable_trifles]).to be_empty
            expect(db[:worthless_junk]).to be_empty
            expect(db[:precious_stones]).to be_empty
          end
        end
      end
    end

    supported_configurations = [
      { :url => 'mysql:///', :connection_options => db_config['mysql'] },
      { :url => 'postgres:///', :connection_options => db_config['postgres'] },
    ]

    supported_configurations.each do |config|
      RSpec.describe "Sequel deletion (using a #{config[:url]} connection)" do
        let(:db) { ::Sequel.connect(config[:url], config[:connection_options]) }

        around do |example|
          helper = SequelHelper.new(config)
          helper.setup

          example.run

          helper.teardown
        end

        it_behaves_like 'a Sequel deletion strategy'
      end
    end
  end
end
