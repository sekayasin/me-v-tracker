FactoryBot.define do
  factory :program do
    sequence(:name) { |n| "#{Faker::Name.first_name}-#{n}" }
    description { Faker::Lorem.paragraph }
    save_status false
    holistic_evaluation true
    estimated_duration 10
    cadence

    factory :create_phase do
      after(:create) do |_program|
        create(:phase, name: "Home Study")
      end
    end
  end
end
