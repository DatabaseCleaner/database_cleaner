def data_mapper_load_schema
  require 'dm-migrations'

  DataMapper.auto_migrate!
end

class ::DmUser
  include DataMapper::Resource

  self.storage_names[:default] = 'users'

  property :id, Serial
  property :name, String

end
