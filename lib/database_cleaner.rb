$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
require 'database_cleaner/configuration'

def DatabaseCleaner(*args)
  DatabaseCleaner.create_strategy(*args)
end
