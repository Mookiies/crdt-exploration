class CreateTimestampTables < ActiveRecord::Migration[6.1]
  def change
    create_table :inspections_timestamps do |t|
      t.string :name_ts

      t.belongs_to :inspection, foreign_key: true, null: false, index: { unique: true }
    end

    create_table :areas_timestamps do |t|
      t.string :name_ts
      t.string :position_ts

      t.belongs_to :area, foreign_key: true, null: false, index: { unique: true }
    end

    create_table :items_timestamps do |t|
      t.string :name_ts
      t.string :note_ts
      t.string :flagged_ts

      t.belongs_to :item, foreign_key: true, null: false, index: { unique: true }
    end
  end
end
