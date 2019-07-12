class ChangeEstimatedDurationDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :programs, :estimated_duration, 0
    Rake::Task['db:update_program_estimation_duration'].invoke
  end
end
