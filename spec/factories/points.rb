FactoryBot.define do
  factory :point do
    sequence(:value) { |n| "#{Faker::Number.between(0, 3)}#{n}" }
    sequence(:context) { |n| "#{Faker::Lorem.word}#{n}" }
  end
end
