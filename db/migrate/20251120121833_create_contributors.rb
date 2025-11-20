class CreateContributors < ActiveRecord::Migration[7.2]
  def change
    create_table :contributors do |t|
      t.text :name, null: false

      t.timestamps
    end
  end
end
