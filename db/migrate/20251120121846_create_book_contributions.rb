class CreateBookContributions < ActiveRecord::Migration[7.2]
  def change
    create_table :book_contributions do |t|
      t.references :book, null: false, foreign_key: true
      t.references :contributor, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.integer :position

      t.timestamps
    end

    add_index :book_contributions, [ :book_id, :contributor_id, :role ], name: "index_book_contributions_on_book_and_contributor_and_role"
  end
end
