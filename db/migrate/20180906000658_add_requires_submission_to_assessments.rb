class AddRequiresSubmissionToAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :assessments, :requires_submission, :boolean, default: false
    Rake::Task["app:add_requires_submission_values_to_assessments"].invoke
  end
end
