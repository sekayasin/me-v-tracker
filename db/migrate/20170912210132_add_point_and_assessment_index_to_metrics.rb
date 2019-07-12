class AddPointAndAssessmentIndexToMetrics < ActiveRecord::Migration[5.0]
  def change
    add_index :metrics, %i[point_id assessment_id], unique: true
  end
end
