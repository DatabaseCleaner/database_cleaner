require 'ohm'

::Ohm.connect :host => "127.0.0.1", :port => 6379, :db => 0

class OhmWidget < Ohm::Model
  attribute :name

  def self.create!(attrs = {})
    new({:name => 'some widget'}.merge(attrs)).save
  end

end
