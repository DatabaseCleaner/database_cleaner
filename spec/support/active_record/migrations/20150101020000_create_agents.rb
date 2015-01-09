class CreateAgents < ActiveRecord::Migration
  def self.up
    create_table :agents do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :agents
  end
end

class ::Agent < ActiveRecord::Base
end
