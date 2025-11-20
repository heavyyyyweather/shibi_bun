class CreateQuotes < ActiveRecord::Migration[7.2]
  def change
    create_table :quotes do |t|
      t.text :body, null: false
      t.integer :status, null: false, default: 1
      t.datetime :published_at
      t.integer :page
      t.text :body_hash
      t.text :admin_note
      t.string :submitted_session_id
      t.string :submitted_ip_hash
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :quotes, [ :book_id, :status ]
    add_index :quotes, [ :book_id, :body_hash ], unique: true, where: "body_hash IS NOT NULL", name: "index_quotes_on_book_id_and_body_hash_unique_when_present"
  end
end
