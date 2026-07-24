class CreateLunchRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :lunch_rooms do |t|
      t.string :name, null: false
      t.string :origin_text, null: false
      t.datetime :lunch_at
      t.datetime :return_by
      t.integer :group_budget_cents
      t.integer :status, null: false, default: 0
      t.string :public_token, null: false
      t.bigint :locked_candidate_id
      t.bigint :backup_candidate_id

      t.timestamps
    end

    add_index :lunch_rooms, :public_token, unique: true
  end
end
