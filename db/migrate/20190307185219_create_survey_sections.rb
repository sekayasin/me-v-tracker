class CreateSurveySections < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_sections do |t|
      t.string :position
      t.references :new_survey, foreign_key: true

      t.timestamps
    end
  end
end
