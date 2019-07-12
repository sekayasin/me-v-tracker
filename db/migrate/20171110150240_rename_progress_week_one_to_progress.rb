class RenameProgressWeekOneToProgress < ActiveRecord::Migration[5.0]
  def change
    rename_column :learner_programs, :progress_week1, :progress
    remove_column :learner_programs, :progress_week2, :integer
    remove_column :learner_programs, :week1_average, :decimal
    remove_column :learner_programs, :week2_average, :decimal
    remove_column :learner_programs, :project_average, :decimal
  end
end
