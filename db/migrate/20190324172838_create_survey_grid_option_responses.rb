class CreateSurveyGridOptionResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_grid_option_responses do |t|
      t.string :question_type
      t.integer :row_id
      t.integer :col_id
      t.integer :question_id
      t.references :survey_response, foreign_key: true

      t.timestamps
    end
  end
end
