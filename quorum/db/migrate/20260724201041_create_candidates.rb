class CreateCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidates do |t|
      t.references :lunch_room, null: false, foreign_key: true
      t.references :research_run, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url
      t.string :address
      t.string :cuisine
      t.string :price_level
      t.integer :walk_minutes
      t.boolean :open_now
      t.text :summary
      t.integer :match_score, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :candidates, [ :lunch_room_id, :match_score ]
    add_foreign_key :lunch_rooms, :candidates, column: :locked_candidate_id
    add_foreign_key :lunch_rooms, :candidates, column: :backup_candidate_id
  end
end
