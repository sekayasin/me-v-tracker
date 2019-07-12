namespace :db do
  desc "Update survey edit response column"
  task update_survey_edit_response: :environment do
    NewSurvey.where(edit_response: nil).each do |survey|
      survey.update(edit_response: false)
    end
    puts "Successfully updated survey edit_response column"
  end
end
