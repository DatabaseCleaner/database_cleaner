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
        it { is_expected.not_to respond_to(:tables_to_truncate) }

        it 'expects #tables_to_truncate to be implemented later' do
          expect{ truncation_example.send :tables_to_truncate }.to raise_error(NotImplementedError)
        end

        it { is_expected.not_to respond_to(:migration_storage_names) }
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
          it { expect(subject.only).to eq ["something"] }
          it { expect(subject.except).to eq [] }
        end

        context "" do
          subject { TruncationExample.new( { :except => ["something"] } ) }
          it { expect(subject.only).to eq nil }
          it { expect(subject.except).to include("something") }
        end

        context "" do
          subject { TruncationExample.new( { :reset_ids => ["something"] } ) }
          it { expect(subject.reset_ids?).to eq true }
        end

        context "" do
          subject { TruncationExample.new( { :reset_ids => nil } ) }
          it { expect(subject.reset_ids?).to eq false }
        end

        context "" do
          subject { TruncationExample.new( { :pre_count => ["something"] } ) }
          it { expect(subject.pre_count?).to eq true }
        end

        context "" do
          subject { TruncationExample.new( { :pre_count => nil } ) }
          it { expect(subject.pre_count?).to eq false }
        end

        context "" do
          subject { MigrationExample.new }
          it { expect(subject.only).to eq nil }
          it { expect(subject.except).to eq %w[migration_storage_name] }
        end

        context "" do
          EXCEPT_TABLES = ["something"]
          subject { MigrationExample.new( { :except => EXCEPT_TABLES } ) }

          it "should not modify the array of excepted tables" do
            expect(subject.except).to include("migration_storage_name")
            expect(EXCEPT_TABLES).not_to include("migration_storage_name")
          end
        end
      end
    end
  end
end
