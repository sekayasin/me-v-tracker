class AddSubmissionTypesToAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :assessments, :submission_types, :string, null: true
  end
end
