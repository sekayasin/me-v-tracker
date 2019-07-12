FactoryBot.define do
  factory :pitch do
    cycle_center
    demo_date { 3.days.from_now }
  end
end
