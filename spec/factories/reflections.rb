FactoryBot.define do
  factory :reflection do
    comment { Faker::Lorem.paragraph }
    feedback
  end
end
