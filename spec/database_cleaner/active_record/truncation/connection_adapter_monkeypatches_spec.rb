require 'support/active_record_helper'
require 'database_cleaner/active_record/truncation'

RSpec.describe DatabaseCleaner::ActiveRecord::Truncation do
  ActiveRecordHelper.with_all_dbs do |helper|
    context "using a #{helper.db} connection" do
      around do |example|
        helper.setup
        example.run
        helper.teardown
      end

      let(:connection) { helper.connection }

      describe "AR connection adapter monkeypatches" do
        describe "#truncate_table" do
          it "truncates the table" do
            2.times { User.create }

            connection.truncate_table('users')

            expect(User.count).to eq 0
          end

          it "truncates the table without id sequence" do
            2.times { Agent.create }

            connection.truncate_table('agents')

            expect(Agent.count).to eq 0
          end

          it "should reset AUTO_INCREMENT index of table" do
            2.times { User.create }
            User.delete_all

            connection.truncate_table('users')

            expect(User.create.id).to eq 1
          end
        end

        unless helper.db == :sqlite3
          describe "#pre_count_truncate_tables" do

            context "with :reset_ids set true" do
              it "truncates the table" do
                2.times { User.create }

                connection.pre_count_truncate_tables(%w[users], :reset_ids => true)
                expect(User.count).to be_zero
              end

              it "resets AUTO_INCREMENT index of table" do
                2.times { User.create }
                User.delete_all

                connection.pre_count_truncate_tables(%w[users]) # true is also the default
                expect(User.create.id).to eq 1
              end
            end


            context "with :reset_ids set false" do
              it "truncates the table" do
                2.times { User.create }

                connection.pre_count_truncate_tables(%w[users], :reset_ids => false)
                expect(User.count).to be_zero
              end

              it "does not reset AUTO_INCREMENT index of table" do
                2.times { User.create }
                User.delete_all

                connection.pre_count_truncate_tables(%w[users], :reset_ids => false)

                expect(User.create.id).to eq 3
              end
            end
          end
        end

        describe ":except option cleanup" do
          it "should not truncate the tables specified in the :except option" do
            2.times { User.create }

            described_class.new(except: ['users']).clean

            expect( User.count ).to eq 2
          end
        end

        describe "schema_migrations table" do
          it "is not truncated" do

            subject.clean

            count = connection.select_value("select count(*) from schema_migrations;").to_i
            expect(count).to eq 2
          end
        end

        if helper.db == :postgres
          describe '#database_cleaner_table_cache' do
            it 'should default to the list of tables with their schema' do
              expect(connection.database_cleaner_table_cache.first).to match(/^public\./)
            end
          end
        end
      end
    end
  end
end
