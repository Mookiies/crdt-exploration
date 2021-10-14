class CreateInspections < ActiveRecord::Migration[6.1]
  def change
    create_table :inspections do |t|
      t.string :name
      t.boolean :tombstone

      t.timestamps
    end
  end
end
