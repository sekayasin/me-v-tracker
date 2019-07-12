class AddIndexToCyclesCenter < ActiveRecord::Migration[5.0]
  def change
    remove_index :cycles_centers, :cycle_center_id
    add_index :cycles_centers, :cycle_center_id, unique: true
  end
end
