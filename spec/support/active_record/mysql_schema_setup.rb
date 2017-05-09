def active_record_load_schema
  ActiveRecord::Schema.define do
    create_table :users, :id => false, :force => true do |t|
      t.column :id, "int(11) auto_increment PRIMARY KEY"
      t.integer :name
    end

    create_table :agents, :id => false, :force => true do |t|
      t.integer :name
    end
  end
end
