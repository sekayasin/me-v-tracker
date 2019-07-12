class SurveyTimeQuestion < ApplicationRecord
  include CheckMinMaxHelper
  after_validation :check_min_max
  has_one :survey_question, as: :questionable, dependent: :destroy
end
