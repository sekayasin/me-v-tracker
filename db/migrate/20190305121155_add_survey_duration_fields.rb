class AddSurveyDurationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :new_surveys, :start_date, :datetime
    add_column :new_surveys, :end_date, :datetime
  end
end
