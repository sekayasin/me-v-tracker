FactoryBot.define do
  factory :feedback do
    learner_program
    phase
    assessment
    impression
    comment { Faker::Lorem.paragraph }
  end
end
