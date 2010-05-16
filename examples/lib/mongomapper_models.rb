require 'mongo_mapper'

::MongoMapper.connection = Mongo::Connection.new('127.0.0.1')
::MongoMapper.database = 'database_cleaner_test'

class MongoWidget
  include MongoMapper::Document
  key :id, Integer
  key :name, String

  class << self
    #mongomapper doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

unless defined? Widget
  class Widget < MongoWidget
  end
else
  class AnotherWidget < MongoWidget
  end
end
