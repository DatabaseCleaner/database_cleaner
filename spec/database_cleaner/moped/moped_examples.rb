module MopedTest
  class ThingBase
    def self.collection
      @session ||= ::ConnectionHelpers::Mongo.build_moped_connection
      @collection ||= @session[name]
    end

    def self.count
      @collection.find.count
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
  class System < ThingBase
    def self.collection
      super
      @collection = @session['system_logs']
    end
  end
end
