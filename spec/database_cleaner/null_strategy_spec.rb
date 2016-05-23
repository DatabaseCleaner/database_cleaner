require 'spec_helper'

module DatabaseCleaner
  describe NullStrategy do
      it 'responds to .start' do
        expect { NullStrategy.start }.not_to raise_error(NoMethodError)
      end

      it 'responds to .clean' do
        expect { NullStrategy.clean }.not_to raise_error(NoMethodError)
      end

      describe '.cleaning' do
        it 'fails without a block' do
          expect { NullStrategy.cleaning }.to raise_error(LocalJumpError)
        end

        it 'no-ops with a block' do
          effect = double
          expect(effect).to receive(:occur).once

          NullStrategy.cleaning do
            effect.occur
          end
        end
      end
  end
end
