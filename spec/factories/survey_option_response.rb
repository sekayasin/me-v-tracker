FactoryBot.define do
  factory :survey_option_response do
    trait :multichoice do
      option_id 1
      question_id 5
      question_type "SurveyMultipleChoiceQuestion"
    end

    trait :picture_option do
      question_type "SurveyPictureOptionQuestion"
      question_id 6
      option_id 1
    end

    trait :dropdown do
      question_type "SurveySelectQuestion"
      question_id 7
      option_id 1
    end
  end
end
