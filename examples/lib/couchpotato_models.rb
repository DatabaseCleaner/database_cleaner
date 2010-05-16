require 'couch_potato'
require 'json/pure'
::CouchPotato::Config.database_name = 'couch_potato_test'

class CouchWidget
  include CouchPotato::Persistence
  
  property :name
  view :by_name, :key => :name
  

  # mimic the AR interface used in example_steps

  def self.create!(attrs = {})
    CouchPotato.database.save(self.new)
  end
  
  def self.count
    CouchPotato.database.view(::Widget.by_name).size
  end
end

unless defined? Widget
  class Widget < CouchWidget
  end
else
  class AnotherWidget < CouchWidget
  end
end
