class CreateCycleCentersNewSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :cycle_centers_new_surveys do |t|
      t.integer :new_survey_id, index: true
      t.string :cycle_center_id, index: true
    end
  end
end
