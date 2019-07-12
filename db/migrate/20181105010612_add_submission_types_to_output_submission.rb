class AddSubmissionTypesToOutputSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :output_submissions, :submission_phase_id, :integer
  end
end
