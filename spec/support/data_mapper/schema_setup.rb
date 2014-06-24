def load_schema
  require 'dm-migrations'

  DataMapper.auto_migrate!
end

class ::User
  include DataMapper::Resource

  property :id, Serial
  property :name, String

end
