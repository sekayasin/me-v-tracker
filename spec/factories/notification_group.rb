FactoryBot.define do
  factory :notification_group do
    name { Faker::Team.name }
  end
end
