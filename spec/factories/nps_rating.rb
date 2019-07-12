FactoryBot.define do
  factory :nps_rating do
    sequence(:nps_ratings_id) { |n| "YTHBERLO #{n}" }
    sequence(:rating) { |n| n }
  end
end
