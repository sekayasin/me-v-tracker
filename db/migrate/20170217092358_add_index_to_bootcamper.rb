class AddIndexToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_index :bootcampers, :camper_id, unique: true
  end
end
