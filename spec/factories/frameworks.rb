FactoryBot.define do
  factory :framework do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    description { Faker::Lorem.paragraph }
  end
end
