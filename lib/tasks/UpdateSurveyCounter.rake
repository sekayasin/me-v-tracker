namespace :db do
  desc "Update survey counters"
  task update_survey_counters: :environment do
    NewSurvey.find_each do |survey|
      NewSurvey.reset_counters(survey.id, :survey_responses)
    end
    puts "Successfully updated survey responses"
  end
end
