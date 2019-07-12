namespace :db do
  desc "Create section for existing surveys"
  task add_sections_for_existing_surveys: :environment do
    SurveyQuestion.all.each do |question|
      section = SurveySection.find_or_create_by!(
        new_survey_id: question.new_survey_id,
        position: question.section
      )
      question.update survey_section_id: section.id
    end
    puts "All sections added and questions updated successfully"
  end
end
