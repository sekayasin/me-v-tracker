class AddColumnToNewSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :new_surveys, :survey_creator, :text
  end
end
