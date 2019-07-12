class RemoveScoresFromBootcampers < ActiveRecord::Migration[5.0]
  def change
    remove_column :bootcampers, :week_one_score
    remove_column :bootcampers, :week_two_score
    remove_column :bootcampers, :final_score
    remove_column :bootcampers, :overall_average
  end
end
