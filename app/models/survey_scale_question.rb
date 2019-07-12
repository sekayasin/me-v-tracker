class SurveyScaleQuestion < ApplicationRecord
  include CheckMinMaxHelper
  after_validation :check_min_max

  validates :min, presence: true
  validates :max, presence: true

  has_one :survey_question, as: :questionable, dependent: :destroy
end
