class CreateSurveyDateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_date_questions do |t|
      t.date :min
      t.date :max

      t.timestamps
    end
  end
end
