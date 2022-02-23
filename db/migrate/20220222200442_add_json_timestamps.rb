class AddJsonTimestamps < ActiveRecord::Migration[6.1]
  def change
    add_column :inspections, :timestamps, :json
  end
end
