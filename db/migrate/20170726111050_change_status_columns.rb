class ChangeStatusColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :bootcampers, :decision_1, :decision_one
    rename_column :bootcampers, :decision_2, :decision_two
  end
end
