FactoryBot.define do
  factory :criterium do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    description { Faker::Lorem.paragraph }
  end
end
