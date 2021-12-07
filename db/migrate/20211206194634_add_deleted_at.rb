class AddDeletedAt < ActiveRecord::Migration[6.1]
  def change
    add_column :inspections, :deleted_at, :datetime
    add_column :areas, :deleted_at, :datetime
    add_column :items, :deleted_at, :datetime
  end
end
