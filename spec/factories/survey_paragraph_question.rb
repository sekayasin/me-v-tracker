FactoryBot.define do
  factory :survey_paragraph_question do
    max_length 100

    trait :wrong_max_length_type do
      max_length nil
    end
  end
end
