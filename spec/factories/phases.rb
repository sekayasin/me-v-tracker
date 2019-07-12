FactoryBot.define do
  factory :phase do
    sequence(:name) { |n| "#{Faker::Name.first_name}-#{n}" }
    phase_duration { Faker::Number.between(1, 5) }
    factory :phase_with_assessments do
      after(:create) do |phase|
        create(:assessment, phases: [phase])
        create(:assessment, phases: [phase])
      end
    end

    factory :phase_assessments do
      assessments { [create(:assessment, :requires_submissions)] }
      phase_duration { 1 }
    end

    factory :phase_with_na_assessments do
      after(:create) do |phase|
        create(:assessment, name: Faker::Name.last_name, phases: [phase])
        create(
          :assessment,
          name: Faker::Name.last_name,
          phases: [phase],
          expectation: "N/A"
        )
      end
    end
  end
end
