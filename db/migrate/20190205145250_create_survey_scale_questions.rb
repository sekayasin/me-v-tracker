class CreateSurveyScaleQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_scale_questions do |t|
      t.integer :min
      t.integer :max

      t.timestamps
    end
  end
end
