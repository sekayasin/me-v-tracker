FactoryBot.define do
  factory :center do
    sequence(:center_id) { |n| "YTHBERLO-#{n}" }
    name { Faker::Address.city }
    country { Faker::Address.country }
  end
end
