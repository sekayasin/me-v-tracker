class CreateSurveyOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_options do |t|
      t.text :option
      t.string :option_type
      t.integer :position
      t.references :survey_option_question, foreign_key: true

      t.timestamps
    end
  end
end
