require "database_cleaner/null_strategy"

module DatabaseCleaner
  RSpec.describe NullStrategy do
    subject(:strategy) { NullStrategy.new }

    it 'responds to .start' do
      expect { strategy.start }.not_to raise_error
    end

    it 'responds to .clean' do
      expect { strategy.clean }.not_to raise_error
    end

    describe '.cleaning' do
      it 'fails without a block' do
        expect { strategy.cleaning }.to raise_error(LocalJumpError)
      end

      it 'no-ops with a block' do
        effect = double
        expect(effect).to receive(:occur).once

        strategy.cleaning do
          effect.occur
        end
      end
    end
  end
end
