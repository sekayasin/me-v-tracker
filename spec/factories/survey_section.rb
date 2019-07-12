FactoryBot.define do
  factory :survey_section do
    position 1

    trait :no_position do
      position nil
    end
  end
end
