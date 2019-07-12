class CreateSurveyOptionQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_option_questions do |t|
      t.string :question_type

      t.timestamps
    end
  end
end
