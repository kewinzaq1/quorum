class CreateResearchRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :research_runs do |t|
      t.references :lunch_room, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :provider, null: false, default: "you.com"
      t.string :provider_task_id
      t.text :query
      t.jsonb :request_payload, null: false, default: {}
      t.jsonb :response_payload, null: false, default: {}
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :research_runs, :provider_task_id, unique: true
    add_index :research_runs, [ :lunch_room_id, :created_at ]
  end
end
