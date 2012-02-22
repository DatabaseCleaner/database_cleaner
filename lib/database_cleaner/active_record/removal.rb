require 'database_cleaner/active_record/base'
require 'database_cleaner/generic/removal'

module DatabaseCleaner::ActiveRecord
  class Removal
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Removal

    # active record use :delete method for removal at clean
    Executor.removal_method = :delete
  end
end
