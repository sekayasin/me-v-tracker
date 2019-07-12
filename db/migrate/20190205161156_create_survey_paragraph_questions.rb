class CreateSurveyParagraphQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_paragraph_questions do |t|
      t.integer :max_length

      t.timestamps
    end
  end
end
