class UpdateSurveyResponseCount < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["db:update_survey_counters"].invoke
  end
end
