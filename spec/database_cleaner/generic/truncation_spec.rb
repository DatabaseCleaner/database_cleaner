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

    class TruncationExampleWithMigrations < TruncationExample
      def migration_storage_names
        %w[migration_storage_name]
      end
    end

    RSpec.describe TruncationExample do
      it "will start" do
        expect { subject.start }.to_not raise_error
      end

      it "expects clean to be implemented later" do
        expect { subject.clean }.to raise_error(NotImplementedError)
      end

      context "private methods" do
        it { is_expected.not_to respond_to(:tables_to_truncate) }

        it 'expects #tables_to_truncate to be implemented later' do
          expect{ subject.send :tables_to_truncate }.to raise_error(NotImplementedError)
        end

        it { is_expected.not_to respond_to(:migration_storage_names) }
      end

      describe "initialize" do
        it "should accept no options" do
          described_class.new
        end

        it "should accept a hash of options" do
          described_class.new({})
        end

        describe ":only option" do
          it "defaults to nil" do
            expect(subject.only).to be_nil
          end

          it "can be set to specify tables to clean" do
            subject = described_class.new(only: ["something"])
            expect(subject.only).to eq ["something"]
          end
        end

        describe ":except option" do
          it "defaults to empty array" do
            expect(subject.except).to eq []
          end

          it "can be set to specify tables to skip" do
            subject = described_class.new(except: ["something"])
            expect(subject.except).to eq ["something"]
          end
        end

        describe ":pre_count option" do
          it "defaults to false" do
            expect(subject.pre_count?).to eq false
          end

          it "can be set" do
            subject = described_class.new(pre_count: "something")
            expect(subject.pre_count?).to eq true
          end
        end

        describe ":reset_ids option" do
          it "defaults to false" do
            expect(subject.reset_ids?).to eq false
          end

          it "can be set" do
            subject = described_class.new(reset_ids: "something")
            expect(subject.reset_ids?).to eq true
          end
        end

        it "should raise an error when invalid options are provided" do
          expect {
            described_class.new(a_random_param: "should raise ArgumentError")
          }.to raise_error(ArgumentError)
        end

        it "should raise an error when :only and :except options are used" do
          expect {
            described_class.new(except: "something", only: "something else")
          }.to raise_error(ArgumentError)
        end

        describe TruncationExampleWithMigrations do
          it { expect(subject.only).to eq nil }
          it { expect(subject.except).to eq %w[migration_storage_name] }

          it "should not mutate the array of excepted tables" do
            except_tables = ["something"]
            subject = described_class.new(except: except_tables)
            expect(subject.except).to eq ["something", "migration_storage_name"]
            expect(except_tables).to eq ["something"]
          end
        end
      end
    end
  end
end
