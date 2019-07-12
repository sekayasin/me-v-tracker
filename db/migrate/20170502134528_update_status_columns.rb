class UpdateStatusColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :status_week2, :string
    rename_column :bootcampers, :status, :status_week1
  end
end
