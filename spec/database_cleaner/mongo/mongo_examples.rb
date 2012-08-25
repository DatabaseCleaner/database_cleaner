module MongoTest
  class ThingBase
    def self.collection
      @connection ||= ::Mongo::Connection.new('127.0.0.1')
      @db ||= @connection.db('database_cleaner_specs')
      @mongo ||= @db.collection(name) || @db.create_collection(name)
    end

    def self.count
      @mongo.count
    end

    def initialize(attrs={})
      @attrs = attrs
    end

    def save!
      self.class.collection.insert(@attrs)
    end
  end

  class Widget < ThingBase
  end
  class Gadget < ThingBase
  end
end
