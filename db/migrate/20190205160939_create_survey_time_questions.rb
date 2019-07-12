class CreateSurveyTimeQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_time_questions do |t|
      t.time :min
      t.time :max

      t.timestamps
    end
  end
end
