FactoryBot.define do
  factory :decision do
    decision_stage 1
    learner_program
    comment { Faker::Lorem.paragraph }

    decision_reason do
      create(:decision_reason, reason: Faker::Lorem.sentence)
    end
  end
end
