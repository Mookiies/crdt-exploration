class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :note
      t.boolean :flagged, null: false, default: false
      t.boolean :tombstone, null: false, default: false
      t.belongs_to :area, foreign_key: true, null: false

      t.timestamps
    end
  end
end
