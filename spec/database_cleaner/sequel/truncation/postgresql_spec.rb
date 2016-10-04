require 'spec_helper'
require 'database_cleaner/sequel/truncation'
require 'database_cleaner/shared_strategy'
require 'sequel'

# XXX: use ActiveRecord's db_config (`db/config.yml`) for CI/dev convenience
require 'support/active_record/database_setup'

module DatabaseCleaner
  module Sequel
    describe do
      let(:db) { ::Sequel.connect('postgres:///', db_config['postgres']) }
      let(:truncation) { Truncation.new(options).tap { |t| t.db = db } }
      let(:options) { {} }

      describe "with multiple schemas" do
        before(:each) do
          db << %{
            -- PG 9.2 doesn't support IF NOT EXISTS
            DROP SCHEMA schema2 CASCADE;"
            CREATE SCHEMA schema2;
            SET search_path = public, schema2;
            CREATE TABLE schema2.users (id int);
            CREATE TABLE schema2.schema2_table (id int);
          }
        end

        after(:each) do
          db << "DROP SCHEMA schema2 CASCADE"
        end

        it "knows about all the tables" do
          truncation.send(:tables_to_truncate, db).should include(:schema2__users)
        end

        it "truncates all the tables" do
          2.times do |n|
            db << "INSERT INTO schema2.users VALUES(#{n}); INSERT INTO schema2_table VALUES(#{n})"
          end

          truncation.clean

          expect(db[:schema2__users].count).to eq(0)
        end

        describe "with only" do
          context "when it contains a symbol" do
            let(:options) { { only: [:schema2__users]} }

            it "only truncates the correct table" do
              2.times do |n|
                db << "INSERT INTO schema2.users VALUES(#{n})"
                db << "INSERT INTO public.users(id) VALUES(#{n})"
              end

              truncation.clean
              expect(db[:schema2__users].count).to eq(0)
              expect(db[:public__users].count).to eq(2)
            end
          end
        end
      end

      describe "tables with a double underscore" do
        before(:each) do
          db << "CREATE TABLE i__have__underscores (id int)"
          2.times { db << "INSERT INTO i__have__underscores VALUES(1)" }
        end

        after(:each) do
          db << "DROP TABLE i__have__underscores"
        end

        it "works" do
          truncation.clean
          expect(db[:i__have__underscores.identifier].count).to eq(0)
        end

        context "with only" do
          let(:options) { { only: ["i__have__underscores"]} }

          it "works" do
            truncation.clean
            expect(db[:i__have__underscores.identifier].count).to eq(0)
          end
        end
      end
    end
  end
end
