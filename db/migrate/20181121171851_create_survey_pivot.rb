class CreateSurveyPivot < ActiveRecord::Migration[5.0]
  def change
    create_table :surveys_pivots do |t|
      t.string :survey_id
      t.string :surveyable_id
      t.string :surveyable_type
    end

    add_index :surveys_pivots, %i(surveyable_type surveyable_id)
  end
end
