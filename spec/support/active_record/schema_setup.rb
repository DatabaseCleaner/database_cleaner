def load_schema
  ActiveRecord::Schema.define do
    create_table :users, :force => true do |t|
      t.integer :name
    end
  end
end

class ::User < ActiveRecord::Base
end
