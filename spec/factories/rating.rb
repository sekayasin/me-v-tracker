FactoryBot.define do
  factory :rating do
    panelist
    learners_pitch
    ui_ux { 3 }
    api_functionality { 3 }
    error_handling { 3 }
    project_understanding { 3 }
    presentational_skill { 3 }
    decision { "Yes" }
    comment Faker::Lorem.sentence
  end
end
