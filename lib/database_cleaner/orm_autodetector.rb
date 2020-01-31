module DatabaseCleaner
  class ORMAutodetector
    ORMS = {
      active_record: "ActiveRecord",
      data_mapper: "DataMapper",
      mongo_mapper: "MongoMapper",
      mongoid: "Mongoid",
      couch_potato: "CouchPotato",
      sequel: "Sequel",
      moped: "Moped",
      ohm: "Ohm",
      redis: "Redis",
      neo4j: "Neo4j",
    }

    def orm
      @autodetected = true
      autodetected_orm or raise no_orm_detected_error
      ORMS.key(autodetected_orm.to_s)
    end

    def autodetected?
      !!@autodetected
    end

    private

    def autodetected_orm
      ORMS.values.find do |orm|
        Kernel.const_get(orm) rescue next
      end
    end

    def no_orm_detected_error
      orm_list = ORMS.values.join(", ").sub(ORMS.values.last, "or #{ORMS.values.last}")
      NoORMDetected.new("No known ORM was detected!  Is #{orm_list} loaded?")
    end
  end
  private_constant :ORMAutodetector
end
