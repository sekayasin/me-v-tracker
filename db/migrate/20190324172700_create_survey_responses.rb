class CreateSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_responses do |t|
      t.string :respondable_id
      t.string :respondable_type
      t.references :new_survey, foreign_key: true

      t.timestamps
    end
  end
end
