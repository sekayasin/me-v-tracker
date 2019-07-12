class SurveyResponse < ApplicationRecord
  validates :new_survey_id, presence: true
  validates :respondable_id, presence: true
  validates :respondable_type,
            presence: true,
            inclusion: {
              in: %w(
                Bootcamper
                Facilitator
              ),
              on: %i(create update),
              message: "is invalid"
            }
  has_many :survey_date_responses, dependent: :destroy
  has_many :survey_grid_option_responses, dependent: :destroy
  has_many :survey_option_responses, dependent: :destroy
  has_many :survey_paragraph_responses, dependent: :destroy
  has_many :survey_time_responses, dependent: :destroy
  has_many :survey_scale_responses, dependent: :destroy

  belongs_to :new_survey, counter_cache: true
  belongs_to :respondable, polymorphic: true
end
