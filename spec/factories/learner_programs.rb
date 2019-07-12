FactoryBot.define do
  factory :learner_program do
    bootcamper
    week_one_facilitator
    week_two_facilitator
    decision_two "Not Applicable"
    overall_average "2.2"
    value_average "2.4"
    output_average "2.6"
    feedback_average "1.5"
    program
    cycle_center
    dlc_stack

    trait :inactive do
      decision_one "Advanced"
      decision_two "Accepted"
      cycle_center { create :cycle_center, :inactive }
    end

    trait :empty_startdate do
      decision_one "Advanced"
      decision_two "Accepted"
      cycle_center { build :cycle_center, :empty_start_date }
    end

    trait :accepted do
      decision_one "Advanced"
      decision_two "Accepted"
    end

    trait :ongoing do
      decision_one "In Progress"
      decision_two "Not Applicable"
    end
  end
end
