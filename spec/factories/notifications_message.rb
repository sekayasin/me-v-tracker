FactoryBot.define do
  factory :notifications_message do
    priority { Faker::Team.name }
    notification_group_id { Faker::Number.non_zero_digit }
    content { Faker::Lorem.sentence }
  end
end
