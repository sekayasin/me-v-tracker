FactoryBot.define do
  factory :survey_date_question do
    min { 5.days.from_now }
    max { 1.weeks.from_now }

    trait :wrong_min_max_type do
      min "wrong"
      max "wrong"
    end
  end
end
