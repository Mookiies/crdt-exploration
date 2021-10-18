class CreateInspections < ActiveRecord::Migration[6.1]
  def change
    create_table :inspections do |t|
      t.string :name, null: false
      t.boolean :tombstone, null: false, default: false

      t.timestamps
    end
  end
end
