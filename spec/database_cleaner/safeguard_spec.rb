require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/transaction'

module DatabaseCleaner
  describe Safeguard do
    let(:strategy) { DatabaseCleaner::ActiveRecord::Transaction }
    let(:cleaner)  { Base.new(:autodetect) }

    before { allow_any_instance_of(strategy).to receive(:start) }

    describe 'DATABASE_URL is set' do
      before { stub_const('ENV', 'DATABASE_URL' => database_url) }

      describe 'to any value' do
        let(:database_url) { 'postgres://remote.host' }

        it 'raises' do
          expect { cleaner.start }.to raise_error(Safeguard::Error::RemoteDatabaseUrl)
        end
      end

      describe 'to a localhost url' do
        let(:database_url) { 'postgres://localhost' }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'to a 127.0.0.1 url' do
        let(:database_url) { 'postgres://127.0.0.1' }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL is set' do
        let(:database_url) { 'postgres://remote.host' }
        before { stub_const('ENV', 'DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL' => true) }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DatabaseCleaner.allow_remote_database_url is true' do
        let(:database_url) { 'postgres://remote.host' }
        before { DatabaseCleaner.allow_remote_database_url = true }
        after  { DatabaseCleaner.allow_remote_database_url = nil }

        it 'does not raise' do
          expect { cleaner.start }.to_not raise_error
        end
      end

      describe 'DatabaseCleaner.url_whitelist is set' do
        let(:url_whitelist) { ['postgres://postgres@localhost', 'postgres://foo.bar'] }

        before { DatabaseCleaner.url_whitelist = url_whitelist }
        after  { DatabaseCleaner.url_whitelist = nil }

        describe 'A remote url is on the whitelist' do
          let(:database_url) { 'postgres://foo.bar' }

          it 'does not raise' do
            expect { cleaner.start }.to_not raise_error
          end
        end

        describe 'A remote url is not on the whitelist' do
          let(:database_url) { 'postgress://bar.baz' }

          it 'raises a whitelist error' do
            expect { cleaner.start }.to raise_error(Safeguard::Error::NotWhitelistedUrl)
          end
        end

        describe 'A local url is on the whitelist' do
          let(:database_url) { 'postgres://postgres@localhost' }

          it 'does not raise' do
            expect { cleaner.start }.to_not raise_error
          end
        end

        describe 'A local url is not on the whitelist' do
          let(:database_url) { 'postgres://localhost' }

          it 'raises a whitelist error' do
            expect { cleaner.start }.to raise_error(Safeguard::Error::NotWhitelistedUrl)
          end
        end
      end
    end

    describe 'ENV is set to production' do
      %w(ENV RACK_ENV RAILS_ENV).each do |key|
        describe "on #{key}" do
          before { stub_const('ENV', key => "production") }

          it 'raises' do
            expect { cleaner.start }.to raise_error(Safeguard::Error::ProductionEnv)
          end
        end

        describe 'DATABASE_CLEANER_ALLOW_PRODUCTION is set' do
          before { stub_const('ENV', 'DATABASE_CLEANER_ALLOW_PRODUCTION' => true) }

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
