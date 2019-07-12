FactoryBot.define do
  factory :survey_pivot do
    association :surveyable, factory: :cycle_center
    association :survey, factory: :survey
  end
end
