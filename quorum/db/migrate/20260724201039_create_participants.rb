class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.references :lunch_room, null: false, foreign_key: true
      t.string :name, null: false
      t.text :diet
      t.text :dislikes
      t.integer :max_walk_minutes
      t.integer :budget_cents
      t.datetime :hard_stop

      t.timestamps
    end

    add_index :participants, [ :lunch_room_id, :name ]
  end
end
