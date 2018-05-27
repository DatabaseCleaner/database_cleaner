require 'active_support/core_ext/string/inflections'

module DatabaseCleaner
  class ORMAutodetector
    ORMS = %w[ActiveRecord DataMapper MongoMapper Mongoid CouchPotato Sequel Moped Ohm Redis Neo4j]

    def orm
      @autodetected = true
      autodetected_orm or raise no_orm_detected_error
      autodetected_orm.underscore.to_sym
    end

    def autodetected?
      !!@autodetected
    end

    private

    def autodetected_orm
      ORMS.find do |orm|
        Kernel.const_get(orm) rescue next
      end
    end

    def no_orm_detected_error
      orm_list = ORMS.join(", ").sub(ORMS.last, "or #{ORMS.last}")
      NoORMDetected.new("No known ORM was detected!  Is #{orm_list} loaded?")
    end
  end
  private_constant :ORMAutodetector
end
