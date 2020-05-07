module MongoTest
  class Base
    def self.collection
      @connection ||= Mongo::Connection.new('127.0.0.1')
      @db ||= @connection.db('database_cleaner_specs')
      @collection ||= @db.collection(name) || @db.create_collection(name)
    end

    def self.count
      @collection.count
    end

    def initialize(attrs={})
      @attrs = attrs
    end

    def save!
      self.class.collection.insert(@attrs)
    end
  end

  class Widget < Base
  end
  class Gadget < Base
  end
  class Gizmo < Base
  end
end
