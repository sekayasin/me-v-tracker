class AddPhaseIdToAssessmentOutputSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :assessment_output_submissions, :phase_id, :integer
  end
end
