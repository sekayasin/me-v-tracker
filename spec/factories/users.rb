FactoryBot.define do
  factory :user do
    skip_create

    user_info do
      {
        id: "-KXGy1MU1oimjQgFimCR",
        email: "rehema.wachira@andela.com",
        first_name: "Rehema",
        last_name: "Wachira",
        name: "Rehema Wachira",
        picture: "",
        andelan: true,
        roles: {
          Fellow: "-KXGy1EB1oimjQgFim6C"
        },
        permissions: {
          "TRACK_VOF" => "-KXGy1EB1oimjQgFim6C",
          "MANAGE_VOF" => "-KXGy1MU1oimjQgFimCR"
        },
        exp: 1_486_630_160
      }
    end
    trait :admin do
      user_info do
        {
          id: "-KXGy1MU1oimjQgFimCR",
          email: "oluwatomi.duyile@andela.com",
          first_name: "Oluwatomi",
          last_name: "Duyile",
          name: "Duyile Oluwatomi",
          admin: true,
          lfa: false,
          picture: "",
          roles: {
            VOF_Admin: "-KdN3P3b8y3X77X8AcJX"
          },
          permissions: {
            "TRACK_VOF" => "-KXGy1EB1oimjQgFim6C",
            "MANAGE_VOF" => "-KXGy1MU1oimjQgFimCR"
          },
          exp: 1_486_630_160
        }
      end
    end

    trait :facilitator do
      user_info do
        {
          id: "-KXGy1MU1oimjQgFimCR",
          email: "oluwatomi.duyile@andela.com",
          first_name: "Oluwatomi",
          last_name: "Duyile",
          name: "Duyile Oluwatomi",
          # admin: true,
          lfa: true,
          picture: "",
          roles: {
            Fellow: "-KdN3P3b8y3X77X8AcJX"
          },
          permissions: {
            "TRACK_VOF" => "-KXGy1EB1oimjQgFim6C",
            "MANAGE_VOF" => "-KXGy1MU1oimjQgFimCR"
          },
          exp: 1_486_630_160
        }
      end
    end

    trait :not_user do
      user_info do
        {
          id: "-KXGy1MU1oimjQgFimCR",
          email: "oluwatomi@gmail.com",
          first_name: "Oluwatomi",
          last_name: "Duyile",
          name: "Duyile Oluwatomi",
          picture: ""
        }
      end
    end
  end
end

def FactoryBot.get_test_user_details(bootcamper)
  {
    learner_info: {
      email: "testuser@email.com",
      country: "Nigeria",
      city: "Lagos",
      gender: "Female",
      format: :json
    },
    id: bootcamper[:camper_id],
    learner_program_id: bootcamper.learner_programs[0][:id]
  }
end
