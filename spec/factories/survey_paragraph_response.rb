FactoryBot.define do
  factory :survey_paragraph_response do
    question_id 1
    question_type SurveyParagraphQuestion
    value { Faker::Lorem.sentence }
  end
end
