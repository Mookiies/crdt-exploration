require 'securerandom'

class AddUuidToInspection < ActiveRecord::Migration[6.1]
  def up
    add_column :inspections, :uuid, :string, unique: true
    add_column :areas, :uuid, :string, unique: true
    add_column :items, :uuid, :string, unique: true

    Inspection.find_each do |inspection|
      inspection.uuid = SecureRandom.uuid
      inspection.save!
    end
    Area.find_each do |area|
      area.uuid = SecureRandom.uuid
      area.save!
    end
    Item.find_each do |item|
      item.uuid = SecureRandom.uuid
      item.save!
    end

    change_column_null :inspections, :uuid, false
    change_column_null :areas, :uuid, false
    change_column_null :items, :uuid, false

    add_index :inspections, :uuid, unique: true
    add_index :areas, :uuid, unique: true
    add_index :items, :uuid, unique: true
  end

  def down
    remove_column :inspections, :uuid
    remove_column :areas, :uuid
    remove_column :items, :uuid
  end
end
