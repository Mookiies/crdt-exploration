class CreateAreas < ActiveRecord::Migration[6.1]
  def change
    create_table :areas do |t|
      t.string :name
      t.integer :position
      t.boolean :tombstone
      t.belongs_to :inspection, foreign_key: true

      t.timestamps
    end
  end
end
