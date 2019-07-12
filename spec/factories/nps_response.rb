FactoryBot.define do
  factory :nps_response do
    sequence(:nps_response_id) { |n| "YTHBERLO #{n}" }
    association :nps_rating, factory: :nps_rating
    association :nps_question, factory: :nps_question
    association :cycle_center, factory: :cycle_center
  end
end
