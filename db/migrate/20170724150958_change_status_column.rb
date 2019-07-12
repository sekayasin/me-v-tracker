class ChangeStatusColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :bootcampers, :status_week1, :decision_1
    rename_column :bootcampers, :status_week2, :decision_2
  end
end
