class SurveySection < ApplicationRecord
  validates :position, presence: true
  validates :new_survey_id, presence: true

  belongs_to :new_survey
  has_many :survey_questions, dependent: :destroy
  has_many :survey_section_rules, dependent: :destroy
end
