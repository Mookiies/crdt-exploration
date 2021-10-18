class CreateAreas < ActiveRecord::Migration[6.1]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.integer :position
      t.boolean :tombstone, null: false, default: false
      t.belongs_to :inspection, foreign_key: true, null: false

      t.timestamps
    end
  end
end
