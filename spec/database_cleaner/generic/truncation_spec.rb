require 'spec_helper'
require 'database_cleaner/generic/truncation'

module ::DatabaseCleaner
  module Generic
    class TruncationExample
      include ::DatabaseCleaner::Generic::Truncation

      def only
        @only
      end

      def except
        @tables_to_exclude
      end

      def reset_ids?
        !!@reset_ids
      end

      def pre_count?
        !!@pre_count
      end
    end

    class MigrationExample < TruncationExample
      def migration_storage_names
        %w[migration_storage_name]
      end
    end

    describe TruncationExample do
      subject(:truncation_example) { TruncationExample.new }

      it "will start" do
        expect { truncation_example.start }.to_not raise_error
      end

      it "expects clean to be implemented later" do
        expect { truncation_example.clean }.to raise_error(NotImplementedError)
      end

      context "private methods" do
        it { should_not respond_to(:tables_to_truncate) }

        it 'expects #tables_to_truncate to be implemented later' do
          expect{ truncation_example.send :tables_to_truncate }.to raise_error(NotImplementedError)
        end

        it { should_not respond_to(:migration_storage_names) }
        its(:migration_storage_names) { should be_empty }
      end

      describe "initialize" do
        it { expect{ subject }.to_not raise_error }

        it "should accept a hash of options" do
          expect{ TruncationExample.new {} }.to_not raise_error
        end

        it { expect{ TruncationExample.new( { :a_random_param => "should raise ArgumentError"  } ) }.to     raise_error(ArgumentError) }
        it { expect{ TruncationExample.new( { :except => "something",:only => "something else" } ) }.to     raise_error(ArgumentError) }
        it { expect{ TruncationExample.new( { :only   => "something"                           } ) }.to_not raise_error }
        it { expect{ TruncationExample.new( { :except => "something"                           } ) }.to_not raise_error }
        it { expect{ TruncationExample.new( { :pre_count => "something"                        } ) }.to_not raise_error }
        it { expect{ TruncationExample.new( { :reset_ids => "something"                        } ) }.to_not raise_error }

        context "" do
          subject { TruncationExample.new( { :only => ["something"] } ) }
          its(:only)   { should eq ["something"] }
          its(:except) { should eq [] }
        end

        context "" do
          subject { TruncationExample.new( { :except => ["something"] } ) }
          its(:only)   { should eq nil }
          its(:except) { should include("something") }
        end

        context "" do
          subject { TruncationExample.new( { :reset_ids => ["something"] } ) }
          its(:reset_ids?) { should eq true }
        end

        context "" do
          subject { TruncationExample.new( { :reset_ids => nil } ) }
          its(:reset_ids?) { should eq false }
        end

        context "" do
          subject { TruncationExample.new( { :pre_count => ["something"] } ) }
          its(:pre_count?) { should eq true }
        end

        context "" do
          subject { TruncationExample.new( { :pre_count => nil } ) }
          its(:pre_count?) { should eq false }
        end

        context "" do
          subject { MigrationExample.new }
          its(:only)   { should eq nil }
          its(:except) { should eq %w[migration_storage_name] }
        end

        context "" do
          EXCEPT_TABLES = ["something"]
          subject { MigrationExample.new( { :except => EXCEPT_TABLES } ) }

          it "should not modify the array of excepted tables" do
            subject.except.should include("migration_storage_name")
            EXCEPT_TABLES.should_not include("migration_storage_name")
          end
        end
      end
    end
  end
end
