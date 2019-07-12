class CreateNewSurveyCollaborators < ActiveRecord::Migration[5.0]
  def change
    create_table :new_survey_collaborators do |t|
      t.references :new_survey, foreign_key: true
      t.references :collaborator, foreign_key: true

      t.timestamps
    end
  end
end
