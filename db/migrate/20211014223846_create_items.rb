class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :note
      t.boolean :flagged
      t.boolean :tombstone
      t.belongs_to :area, foreign_key: true

      t.timestamps
    end
  end
end
