class SurveyParagraphQuestion < ApplicationRecord
  has_one :survey_question, as: :questionable, dependent: :destroy
end
