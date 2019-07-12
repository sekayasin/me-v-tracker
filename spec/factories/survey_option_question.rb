FactoryBot.define do
  factory :survey_option_question do
    question_type "SurveyMultipleChoiceQuestion"

    trait :wrong_type do
      question_type "wrong"
    end

    trait :checkbox do
      question_type "SurveyCheckboxQuestion"
    end

    trait :multichoice do
      question_type "SurveyMultipleChoiceQuestion"
    end

    trait :picture_checkbox do
      question_type "SurveyPictureCheckboxQuestion"
    end

    trait :picture_multichoice do
      question_type "SurveyPictureCheckboxQuestion"
    end

    trait :multigrid_multichoice do
      question_type "SurveyMultigridOptionQuestion"
    end

    trait :multigrid_checkbox do
      question_type "SurveyMultigridCheckboxQuestion"
    end
  end
end
