class SurveySectionRule < ApplicationRecord
  validates :survey_section_id, presence: true
  validates :survey_option_id, presence: true

  belongs_to :survey_section
  belongs_to :survey_option
end
