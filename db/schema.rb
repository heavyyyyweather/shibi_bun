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

ActiveRecord::Schema[7.2].define(version: 2025_11_20_121938) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_contributions", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "contributor_id", null: false
    t.integer "role", default: 0, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "contributor_id", "role"], name: "index_book_contributions_on_book_and_contributor_and_role"
    t.index ["book_id"], name: "index_book_contributions_on_book_id"
    t.index ["contributor_id"], name: "index_book_contributions_on_contributor_id"
  end

  create_table "books", force: :cascade do |t|
    t.text "title", null: false
    t.text "publisher"
    t.date "published_on"
    t.string "isbn13", limit: 13
    t.text "cover_url"
    t.integer "api_provider", default: 2, null: false
    t.datetime "api_synced_at"
    t.datetime "source_updated_at"
    t.jsonb "api_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn13"], name: "index_books_on_isbn13", unique: true
  end

  create_table "contributors", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.text "body", null: false
    t.integer "status", default: 1, null: false
    t.datetime "published_at"
    t.integer "page"
    t.text "body_hash"
    t.text "admin_note"
    t.string "submitted_session_id"
    t.string "submitted_ip_hash"
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "body_hash"], name: "index_quotes_on_book_id_and_body_hash_unique_when_present", unique: true, where: "(body_hash IS NOT NULL)"
    t.index ["book_id", "status"], name: "index_quotes_on_book_id_and_status"
    t.index ["book_id"], name: "index_quotes_on_book_id"
  end

  add_foreign_key "book_contributions", "books"
  add_foreign_key "book_contributions", "contributors"
  add_foreign_key "quotes", "books"
end
