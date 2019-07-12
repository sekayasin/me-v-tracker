FactoryBot.define do
  factory :bootcamper do
    sequence(:camper_id) { |n| "YTHBERLO #{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name.gsub(/[^A-Za-z]/, "") }
    gender "Female"
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    github { "https://github.com/learner" }
    linkedin { "https://www.linkedin.com/in/learner" }
    trello { "learner" }
    website { Faker::Internet.url }
    about { Faker::Lorem.paragraph }
    middle_name { Faker::Name.first_name }
    avatar { Faker::Internet.url }

    after(:create) do |bootcamper|
      bootcamper.cycle_centers << FactoryBot.create(:cycle_center)
    end

    factory :bootcamper_with_learner_program do
      after(:create) do |bootcamper|
        create(:learner_program,
               camper_id: bootcamper.id,
               cycle_center: create(:cycle_center))
      end
    end

    factory :bootcamper_with_accepted_decision_status do
      after(:create) do |bootcamper|
        create(
          :learner_program,
          camper_id: bootcamper.id,
          decision_one: "Advanced",
          decision_two: "Accepted"
        )
      end
    end

    factory :bootcamper_with_many_learner_program do
      after(:create) do |bootcamper|
        create_list(:learner_program, 5, camper_id: bootcamper.id)
      end
    end
  end
end
