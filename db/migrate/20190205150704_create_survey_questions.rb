class CreateSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_questions do |t|
      t.text :question
      t.text :description
      t.string :description_type
      t.integer :section
      t.integer :position
      t.boolean :is_required
      t.references :new_survey, foreign_key: true
      t.references :questionable, polymorphic: true

      t.timestamps
    end
  end
end
