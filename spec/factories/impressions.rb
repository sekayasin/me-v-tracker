FactoryBot.define do
  factory :impression do
    sequence :name do |n|
      "#{Faker::StarWars.vehicle}-#{n}"
    end
  end
end
