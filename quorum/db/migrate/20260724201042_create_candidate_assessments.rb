class CreateCandidateAssessments < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_assessments do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.boolean :fits
      t.string :verdict
      t.jsonb :reasons, null: false, default: []

      t.timestamps
    end

    add_index :candidate_assessments, [ :candidate_id, :participant_id ], unique: true
  end
end
