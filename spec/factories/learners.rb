FactoryBot.define do
  factory :learner do
    skip_create

    learner_info do
      {
        id: "-KXGy1MU1oimjQgFimCR",
        email: "john.doe@gmail.com",
        first_name: "John",
        last_name: "Doe",
        name: "John Doe",
        andelan: false,
        picture: "",
        roles: {
          Guest: "-KXGy1EB1oimjQgFim6C"
        },
        exp: 1_486_630_160
      }
    end
  end
end
