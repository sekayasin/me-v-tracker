class AddIndexToPhasesAndAssessments < ActiveRecord::Migration[5.0]
  def change
    add_index :assessments_phases, [:assessment_id, :phase_id], :unique => true
  end
end
