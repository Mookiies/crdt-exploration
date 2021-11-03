class AddNotesToInspection < ActiveRecord::Migration[6.1]
  def change
    add_column :inspections, :note, :text
    add_column :inspections_timestamps, :note, :string
  end
end
