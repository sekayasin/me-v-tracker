class ChangeCamperIdToString < ActiveRecord::Migration[5.0]
  def up
    change_column :bootcampers, :camper_id, :string, null: false
  end

  def down
    change_column :bootcampers, :camper_id, 'integer USING CAST(camper_id AS integer)', null: false
  end
end
