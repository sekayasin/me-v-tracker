FactoryBot.define do
  factory :survey_time_question do
    min { 5.minutes.from_now.strftime("%H:%M") }
    max { 10.hours.from_now.strftime("%H:%M") }

    trait :wrong_min_max_type do
      min "wrong"
      max "wrong"
    end
  end
end
