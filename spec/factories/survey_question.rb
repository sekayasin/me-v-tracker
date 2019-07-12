FactoryBot.define do
  factory :survey_question do
    question { Faker::Lorem.word }
    description_type "text"
    description { Faker::Lorem.sentence }
    position 2
    is_required true

    trait :no_question do
      question nil
    end

    trait :wrong_description_type do
      description_type "wrong"
    end

    trait :no_section do
      survey_section_id nil
    end

    trait :no_position do
      position nil
    end
  end
end
