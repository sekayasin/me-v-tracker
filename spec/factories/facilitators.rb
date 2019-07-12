FactoryBot.define do
  factory :facilitator, aliases: %i(week_one_facilitator
                                    week_two_facilitator) do
                                      sequence(:email) do |n|
                                        "user_#{n}@amdela.com"
                                      end
                                    end
end
