class CreateSurveyParagraphResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_paragraph_responses do |t|
      t.string :question_type
      t.text :value
      t.integer :question_id
      t.references :survey_response, foreign_key: true

      t.timestamps
    end
  end
end
