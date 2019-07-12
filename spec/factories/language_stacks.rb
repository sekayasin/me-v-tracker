FactoryBot.define do
  factory :language_stack do
    sequence(:name) { |n| "#{Faker::Name.first_name}-#{n}" }
    dlc_stack_status false
  end
end
