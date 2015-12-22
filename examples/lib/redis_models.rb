require 'redis'

class RedisWidget

  def self.redis
    threaded ||= Redis.new
  end

  def self.redis=(connection)
    threaded = connection
  end

  def self.threaded
    Thread.current[self.class.to_s] ||= {}
  end

  def initialize(options = {})
    options = options.dup
    @name = options[:name]
  end

  def connection
    self.class.redis
  end

  def save
    unless connection.get(self.class.to_s + ':id')
      @id = 0
      connection.set(self.class.to_s + ':id', @id)
    end
    @id = connection.incr(self.class.to_s + ':id')
    connection.set(self.class.to_s + ':%d:name' % @id, @name)
  end

  def self.count
    self.redis.keys(self.to_s + '*name').size
  end

  def self.create!
    new(:name => 'some widget').save

  end
end

class RedisWidgetUsingDatabaseOne < RedisWidget

  def self.redis
    threaded[self.class.to_s] ||= Redis.new :url => ENV['REDIS_URL_ONE']
  end

  def self.create!
    new(:name => 'a widget using database one').save
  end
end

class RedisWidgetUsingDatabaseTwo < RedisWidget

  def self.redis
    threaded[self.class.to_s] ||= Redis.new :url => ENV['REDIS_URL_TWO']
  end

  def self.create!
    new(:name => 'a widget using database two').save
  end
end
