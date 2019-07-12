class AddHolisticEvaluationAverageToHolisticEvaluation < ActiveRecord::Migration[5.0]
  def change
    add_reference :holistic_evaluations, :holistic_evaluation_average, foreign_key: true
  end
end
