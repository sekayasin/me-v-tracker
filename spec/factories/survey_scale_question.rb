FactoryBot.define do
  factory :survey_scale_question do
    min 1
    max 10

    trait :wrong_min_max do
      min nil
      max true
    end

    trait :no_min do
      min nil
      max 100
    end
  end
end
