class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.references :research_run, null: false, foreign_key: true
      t.references :candidate, null: false, foreign_key: true
      t.string :url
      t.string :title
      t.text :snippet
      t.string :source_type

      t.timestamps
    end

    add_index :sources, :url
  end
end
