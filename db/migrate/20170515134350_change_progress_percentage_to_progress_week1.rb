class ChangeProgressPercentageToProgressWeek1 < ActiveRecord::Migration[5.0]
  def change
    rename_column :bootcampers, :progress_percentage, :progress_week1
    add_column :bootcampers, :progress_week2, :integer
  end
end
