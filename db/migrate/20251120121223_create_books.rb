class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.text :title, null: false
      t.text :publisher
      t.date :published_on
      t.string :isbn13, limit: 13
      t.text :cover_url
      t.integer :api_provider, null: false, default: 2
      t.datetime :api_synced_at
      t.datetime :source_updated_at
      t.jsonb :api_payload

      t.timestamps
    end

    add_index :books, :isbn13, unique: true
  end
end
