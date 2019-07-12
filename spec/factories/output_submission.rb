FactoryBot.define do
  factory :output_submission do
    link { Faker::Internet.url "github.com" }
    description { Faker::Lorem.sentence }
    learner_program
    phase
    assessment
    submission_phase
  end
end
