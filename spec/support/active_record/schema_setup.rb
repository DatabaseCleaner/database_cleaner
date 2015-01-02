def active_record_load_schema
  ActiveRecord::Schema.define do
    create_table :users, :force => true do |t|
      t.integer :name
    end

    create_table :agents, :id => false, :force => true do |t|
      t.integer :name
    end
  end
end

class ::User < ActiveRecord::Base
end

class ::Agent < ActiveRecord::Base
end
