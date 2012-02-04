require 'database_cleaner/data_mapper/base'
require 'database_cleaner/generic/removal'

module DatabaseCleaner::DataMapper
  class Removal
    include ::DatabaseCleaner::DataMapper::Base
    include ::DatabaseCleaner::Generic::Removal

    # data mapper use :destroy for removal at clean
    Executor.removal_method = :destroy
  end
end
