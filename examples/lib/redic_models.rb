require 'redic'

class RedicWidget

  def self.redic
    threaded ||= Redic.new
  end

  def self.redic=(connection)
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
    self.class.redic
  end

  def save
    unless connection.class('GET', self.class.to_s + ':id')
      @id = 0
      connection.call('SET', self.class.to_s + ':id', @id)
    end
    @id = connection.call('INCR', self.class.to_s + ':id')
    connection.call('SET', self.class.to_s + ':%d:name' % @id, @name)
  end

  def self.count
    self.redis.call('KEYS', self.to_s + '*name').size
  end

  def self.create!
    new(:name => 'some widget').save

  end
end

class RedicWidgetUsingDatabaseOne < RedicWidget

  def self.redis
    threaded[self.class.to_s] ||= Redic.new ENV['REDIS_URL_ONE']
  end

  def self.create!
    new(:name => 'a widget using database one').save
  end
end

class RedicWidgetUsingDatabaseTwo < RedicWidget

  def self.redic
    threaded[self.class.to_s] ||= Redic.new ENV['REDIS_URL_TWO']
  end

  def self.create!
    new(:name => 'a widget using database two').save
  end
end
