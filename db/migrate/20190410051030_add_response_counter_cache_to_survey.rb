class AddResponseCounterCacheToSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :new_surveys, :survey_responses_count, :integer
  end
end
