class CreateAreas < ActiveRecord::Migration[6.1]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.integer :position
      t.boolean :tombstone, null: false, default: false
      t.belongs_to :inspection, foreign_key: true, null: false
      t.string :uuid, null: false

      t.timestamps

      t.index :uuid, unique: true
    end
  end
end
