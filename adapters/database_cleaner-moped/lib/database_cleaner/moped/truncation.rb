require 'database_cleaner/moped/truncation_base'

module DatabaseCleaner
  module Moped
    class Truncation
      include ::DatabaseCleaner::Moped::TruncationBase
    end
  end
end
