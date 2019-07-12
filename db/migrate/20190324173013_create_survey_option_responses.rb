class CreateSurveyOptionResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_option_responses do |t|
      t.string :question_type
      t.integer :option_id
      t.integer :question_id
      t.references :survey_response, foreign_key: true

      t.timestamps
    end
  end
end
