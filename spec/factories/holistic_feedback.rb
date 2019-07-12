FactoryBot.define do
  factory :holistic_feedback do
    learner_program
    criterium
    comment { Faker::Lorem.paragraph }
  end
end
