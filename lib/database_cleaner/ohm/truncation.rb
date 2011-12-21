require 'database_cleaner/generic/truncation'
require 'database_cleaner/ohm/base'
require 'database_cleaner/redis/truncation'

module DatabaseCleaner
  module Ohm
    class Truncation
      include ::DatabaseCleaner::Ohm::Base
      include ::DatabaseCleaner::Generic::Truncation
      include ::DatabaseCleaner::Redis::Truncation

    end
  end
end
