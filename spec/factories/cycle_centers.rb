FactoryBot.define do
  factory :cycle_center do
    sequence(:cycle_center_id) { |n| "YTHBERLO #{n}" }
    association :cycle, factory: :cycle
    association :center, factory: :center
    association :program, factory: :program
    start_date Faker::Time.between(4.months.ago, Time.now, :night)
    end_date Date.today

    trait :inactive do
      end_date 1.month.ago
    end

    trait :ongoing do
      end_date 2.days.from_now
    end

    trait :start_today do
      start_date Date.today
      end_date 2.weeks.from_now
    end

    trait :weekend_start_date do
      start_date Date.parse("2018-09-1")
    end

    trait :empty_start_date do
      start_date nil
    end

    trait :empty_end_date do
      start_date nil
      end_date nil
    end

    trait :submission_on_time do
      start_date Date.today
      end_date Faker::Time.between(4.months.from_now, Time.now, :night)
    end
  end
end
