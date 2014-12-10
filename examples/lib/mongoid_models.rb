require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('database_cleaner_test')
end

class MongoidWidget
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoidWidgetUsingDatabaseOne
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end

class MongoidWidgetUsingDatabaseTwo
  include Mongoid::Document
  field :id, :type => Integer
  field :name

  class << self
    #mongoid doesn't seem to provide this...
    def create!(*args)
      new(*args).save!
    end
  end
end
