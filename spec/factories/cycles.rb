FactoryBot.define do
  factory :cycle do
    sequence(:cycle_id) { |n| "YTHBERLO #{n}" }
    sequence(:cycle) { |n| n }
  end
end
