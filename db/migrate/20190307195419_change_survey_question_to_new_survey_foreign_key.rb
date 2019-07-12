class ChangeSurveyQuestionToNewSurveyForeignKey < ActiveRecord::Migration[5.0]
  def change
    add_reference :survey_questions, :survey_section, foreign_key: true
    Rake::Task["db:add_sections_for_existing_surveys"].invoke
    remove_reference :survey_questions, :new_survey, foreign_key: true
    remove_column :survey_questions, :section, :integer
  end
end
