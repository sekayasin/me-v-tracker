FactoryBot.define do
  factory :submission_phase, class: AssessmentOutputSubmission do
    title { Faker::Lorem.word }
    position { 1 }
    sequence(:day, 1)
    assessment
    file_type { "link" }
    phase

    factory :submission_phase_with_submissions do
      transient { count { 3 } }
      after(:create) do |submission_phase, e|
        create_list(:output_submission,
                    e.count,
                    submission_phase: submission_phase)
      end
    end
  end
end
