# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_24_201043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "candidate_assessments", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.boolean "fits"
    t.bigint "participant_id", null: false
    t.jsonb "reasons", default: [], null: false
    t.datetime "updated_at", null: false
    t.string "verdict"
    t.index ["candidate_id", "participant_id"], name: "index_candidate_assessments_on_candidate_id_and_participant_id", unique: true
    t.index ["candidate_id"], name: "index_candidate_assessments_on_candidate_id"
    t.index ["participant_id"], name: "index_candidate_assessments_on_participant_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "cuisine"
    t.bigint "lunch_room_id", null: false
    t.integer "match_score", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.boolean "open_now"
    t.string "price_level"
    t.bigint "research_run_id", null: false
    t.integer "status", default: 0, null: false
    t.text "summary"
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "walk_minutes"
    t.index ["lunch_room_id", "match_score"], name: "index_candidates_on_lunch_room_id_and_match_score"
    t.index ["lunch_room_id"], name: "index_candidates_on_lunch_room_id"
    t.index ["research_run_id"], name: "index_candidates_on_research_run_id"
  end

  create_table "lunch_rooms", force: :cascade do |t|
    t.bigint "backup_candidate_id"
    t.datetime "created_at", null: false
    t.integer "group_budget_cents"
    t.bigint "locked_candidate_id"
    t.datetime "lunch_at"
    t.string "name", null: false
    t.string "origin_text", null: false
    t.string "public_token", null: false
    t.datetime "return_by"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["public_token"], name: "index_lunch_rooms_on_public_token", unique: true
  end

  create_table "participants", force: :cascade do |t|
    t.integer "budget_cents"
    t.datetime "created_at", null: false
    t.text "diet"
    t.text "dislikes"
    t.datetime "hard_stop"
    t.bigint "lunch_room_id", null: false
    t.integer "max_walk_minutes"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["lunch_room_id", "name"], name: "index_participants_on_lunch_room_id_and_name"
    t.index ["lunch_room_id"], name: "index_participants_on_lunch_room_id"
  end

  create_table "research_runs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.bigint "lunch_room_id", null: false
    t.string "provider", default: "you.com", null: false
    t.string "provider_task_id"
    t.text "query"
    t.jsonb "request_payload", default: {}, null: false
    t.jsonb "response_payload", default: {}, null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["lunch_room_id", "created_at"], name: "index_research_runs_on_lunch_room_id_and_created_at"
    t.index ["lunch_room_id"], name: "index_research_runs_on_lunch_room_id"
    t.index ["provider_task_id"], name: "index_research_runs_on_provider_task_id", unique: true
  end

  create_table "sources", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.datetime "created_at", null: false
    t.bigint "research_run_id", null: false
    t.text "snippet"
    t.string "source_type"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["candidate_id"], name: "index_sources_on_candidate_id"
    t.index ["research_run_id"], name: "index_sources_on_research_run_id"
    t.index ["url"], name: "index_sources_on_url"
  end

  add_foreign_key "candidate_assessments", "candidates"
  add_foreign_key "candidate_assessments", "participants"
  add_foreign_key "candidates", "lunch_rooms"
  add_foreign_key "candidates", "research_runs"
  add_foreign_key "lunch_rooms", "candidates", column: "backup_candidate_id"
  add_foreign_key "lunch_rooms", "candidates", column: "locked_candidate_id"
  add_foreign_key "participants", "lunch_rooms"
  add_foreign_key "research_runs", "lunch_rooms"
  add_foreign_key "sources", "candidates"
  add_foreign_key "sources", "research_runs"
end
