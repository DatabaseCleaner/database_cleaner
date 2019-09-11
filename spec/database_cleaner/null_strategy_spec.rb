require "database_cleaner/null_strategy"

module DatabaseCleaner
  RSpec.describe NullStrategy do
    it 'responds to .start' do
      expect { subject.start }.not_to raise_error
    end

    it 'responds to .clean' do
      expect { subject.clean }.not_to raise_error
    end

    describe '.cleaning' do
      it 'fails without a block' do
        expect { subject.cleaning }.to raise_error(LocalJumpError)
      end

      it 'no-ops with a block' do
        effect = double
        expect(effect).to receive(:occur).once

        subject.cleaning do
          effect.occur
        end
      end
    end
  end
end
