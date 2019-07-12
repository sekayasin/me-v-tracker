class UpdateSurveyEditResponseColumn < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["db:update_survey_edit_response"].invoke
  end
end
