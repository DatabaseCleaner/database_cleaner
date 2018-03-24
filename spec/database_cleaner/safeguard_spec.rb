require 'spec_helper'
require 'support/env'
require 'active_record'
require 'database_cleaner/active_record/transaction'

module DatabaseCleaner
  describe Safeguard do
    include Support::Env

    let(:strategy) { DatabaseCleaner::ActiveRecord::Transaction }
    let(:cleaner)  { Base.new(:autodetect) }

    before { allow_any_instance_of(strategy).to receive(:start) }

    describe 'DATABASE_URL is set' do
      describe 'to any value' do
        env DATABASE_URL: 'postgres://remote.host'

        it 'raises' do
          expect { cleaner.start }.to raise_error(Safeguard::Error::RemoteDatabaseUrl)
        end
      end

      describe 'to a local url' do
        env DATABASE_URL: 'postgres://localhost'

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL is set' do
        env DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL: true

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DatabaseCleaner.allow_remote_database_url is true' do
        before { DatabaseCleaner.allow_remote_database_url = true }
        after  { DatabaseCleaner.allow_remote_database_url = nil }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end
    end

    describe 'ENV is set to production' do
      %w(ENV RACK_ENV RAILS_ENV).each do |key|
        describe "on #{key}" do
          env key => 'production'

          it 'raises' do
            expect { cleaner.start }.to raise_error(Safeguard::Error::ProductionEnv)
          end
        end

        describe 'DATABASE_CLEANER_ALLOW_PRODUCTION is set' do
          env DATABASE_CLEANER_ALLOW_PRODUCTION: true

          it 'does not raise' do
            expect { cleaner.start }.to_not raise_error
          end
        end

        describe 'DatabaseCleaner.allow_production is true' do
          before { DatabaseCleaner.allow_production = true }
          after  { DatabaseCleaner.allow_production = nil }

          it 'does not raise' do
            expect { cleaner.start }.to_not raise_error
          end
        end
      end
    end
  end
end
