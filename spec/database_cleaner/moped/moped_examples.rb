module MopedTest
  class ThingBase
    def self.collection
      @db ||= 'database_cleaner_specs'
      @session ||= ::Moped::Session.new(['127.0.0.1:27017'], database: @db)
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
