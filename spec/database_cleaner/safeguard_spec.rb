require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/transaction'

module DatabaseCleaner
  describe Safeguard do
    let(:strategy) { DatabaseCleaner::ActiveRecord::Transaction }
    let(:cleaner)  { Base.new(:autodetect) }

    before { allow_any_instance_of(strategy).to receive(:start) }

    describe 'DATABASE_URL is set' do
      describe 'to any value' do
        before { ENV['DATABASE_URL'] = 'postgres://remote.host' }
        after  { ENV.delete('DATABASE_URL') }

        it 'raises DatabaseUrlSpecified' do
          expect { cleaner.start }.to raise_error(DatabaseUrlSpecified)
        end
      end

      describe 'to a local url' do
        before { ENV['DATABASE_URL'] = 'postgres://localhost' }
        after  { ENV.delete('DATABASE_URL') }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DATABASE_CLEANER_SKIP_SAFEGUARD is set' do
        before { ENV['DATABASE_CLEANER_SKIP_SAFEGUARD'] = 'true' }
        after  { ENV.delete('DATABASE_CLEANER_SKIP_SAFEGUARD') }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end
    end
  end
end
