FactoryBot.define do
  factory :survey do
    sequence(:survey_id) { |n| "YTHBERLO #{n}" }
    title { Faker::Lorem.word }
    link { Faker::Internet.url "github.com" }
    start_date { 5.days.from_now }
    end_date { 1.week.from_now }

    transient do
      with_wrong_link { false }
      with_empty_fields { false }
      with_update_fields { false }
    end

    after(:build) do |survey, e|
      survey.link = Faker::Lorem.word if e.with_wrong_link
      if e.with_empty_fields
        survey.title = ""
        survey.link = ""
      end
      if e.with_update_fields
        survey.title = "Test survey"
        survey.link = "https://www.vof.andela.com"
      end
    end
  end

  factory :schedule_feedback do
    start_date { Time.now }
    end_date { 1.week.from_now }
  end
end
