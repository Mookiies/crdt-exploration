class AddJsonAreaTimestamps < ActiveRecord::Migration[6.1]
  def change
    add_column :areas, :timestamps, :json
    add_column :items, :timestamps, :json
  end
end
