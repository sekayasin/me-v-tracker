FactoryBot.define do
  factory :new_survey do
    title { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    status { "published" }
    survey_creator { "juliet@andela.com" }
    edit_response { true }
    start_date { Time.now }
    end_date { 10.days.from_now }

    trait :no_title do
      title nil
    end

    trait :no_status do
      status nil
    end

    trait :no_duration do
      end_date nil
      start_date nil
    end

    trait :draft do
      status "draft"
      start_date Time.parse("28 Jun 2019")
      end_date Time.parse("29 Jun 2019")
    end

    trait :completed do
      status "completed"
    end

    trait :published do
      status "published"
    end

    trait :wrong_status do
      status "wrong"
    end
  end
end
