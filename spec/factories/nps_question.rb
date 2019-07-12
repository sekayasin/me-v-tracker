FactoryBot.define do
  factory :nps_question do
    sequence(:nps_question_id) { |n| "YTHBERLO-#{n}" }
    question { Faker::Lorem.sentence }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
  end
end
