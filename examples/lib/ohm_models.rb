require 'ohm'
require 'redis'

Ohm.redis = Redic.new ENV['REDIS_URL']

class OhmWidget < Ohm::Model
  attribute :name

  def self.create!(attrs = {})
    new({:name => 'some widget'}.merge(attrs)).save
  end

  def self.count
    all.count
  end

end

class OhmWidgetUsingDatabaseOne < Ohm::Model
  Ohm.redis = Redic.new ENV['REDIS_URL_ONE']
  attribute :name

  def self.create!(attrs = {})
    new({:name => 'a widget using database one'}.merge(attrs)).save
  end

  def self.count
    all.count
  end

end

class OhmWidgetUsingDatabaseTwo < Ohm::Model
  Ohm.redis = Redic.new ENV['REDIS_URL_TWO']
  attribute :name

  def self.create!(attrs = {})
    new({:name => 'a widget using database two'}.merge(attrs)).save
  end

  def self.count
    all.count
  end
end
