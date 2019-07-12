class RenameEvaluationAverageAverageToHolisticAverage < ActiveRecord::Migration[5.0]
  def change
    rename_column :evaluation_averages, :average, :holistic_average
  end
end
