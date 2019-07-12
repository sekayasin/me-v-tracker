FactoryBot.define do
  factory :score do
    assessment
    score Faker::Number.between(0, 2)
    week 1
    learner_program
    phase
    comments Faker::Lorem.sentence
  end
end
