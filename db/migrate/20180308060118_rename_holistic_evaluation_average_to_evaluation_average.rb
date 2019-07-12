class RenameHolisticEvaluationAverageToEvaluationAverage < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :holistic_evaluations, :holistic_evaluation_averages
    rename_table :holistic_evaluation_averages, :evaluation_averages
    rename_column :holistic_evaluations,
                  :holistic_evaluation_average_id,
                  :evaluation_average_id
    add_foreign_key :holistic_evaluations, :evaluation_averages
  end
end
