FactoryBot.define do
  factory :survey_option do
    option_type { %w(text image row column).sample }
    option do
      case option_type
      when "text", "row", "column"
        Faker::Lorem.words
      when "image"
        "http://placehold.it/200x200"
      end
    end
    position do
      if %w(row column).include?(option_type)
        Faker::Number.non_zero_digit
      end
    end

    trait :with_text_option do
      option_type "text"
      option { Faker::Lorem.word }
    end

    trait :with_image_option do
      option_type "image"
      option "http://placehold.it/200x200"
    end

    trait :with_row_option do
      option_type "row"
      option { Faker::Lorem.word }
    end

    trait :with_column_option do
      option_type "column"
      option { Faker::Lorem.word }
    end

    trait :with_row_option do
      option_type "row"
      option { Faker::Lorem.word }
    end

    trait :with_position do
      position { Faker::Number.non_zero_digit }
    end

    trait :without_position do
      position nil
    end

    trait :wrong_option_type do
      option_type "wrong"
    end

    trait :with_row do
      option_type "row"
    end
  end
end
