FactoryBot.define do
  factory :holistic_evaluation do
    learner_program
    criterium
    evaluation_average
    score 1
    comment { Faker::Lorem.paragraph }
  end
end

def FactoryBot.create_custom_evaluation(
  score,
  learner_program,
  criterium,
  evaluation_average_id
)
  HolisticEvaluation.create(
    score: score,
    comment: Faker::Lorem.paragraph,
    learner_program_id: learner_program.id,
    criterium_id: criterium.id,
    evaluation_average_id: evaluation_average_id,
    created_at: Time.now.getutc
  )
end
