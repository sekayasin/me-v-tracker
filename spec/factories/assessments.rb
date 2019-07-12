FactoryBot.define do
  factory :assessment do
    sequence(:name) { |n| "Simple assessment-#{n}" }
    description { Faker::Lorem.word }
    requires_submission { Faker::Boolean.boolean }
    submission_types { Faker::Lorem.word }
    context { Faker::Lorem.word }
    expectation { Faker::Lorem.word }
    framework_criterium

    trait :long_description do
      description { Faker::Lorem.sentence(200) }
    end

    trait :requires_submissions do
      requires_submission true
    end

    transient do
      with_submissions { false }
    end

    after(:create) do |assessment, e|
      if e.with_submissions
        create_list(:submission_phase, 4,
                    assessment: assessment,
                    phase: e.phases.first)
      end
    end

    factory :assessment_with_phases do
      after(:create) do |assessment|
        create(:phase, assessments: [assessment])
        create(:phase, name: "Project assessment", assessments: [assessment])
      end
    end
  end
end
