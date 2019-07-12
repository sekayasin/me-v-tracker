class SurveyOption < ApplicationRecord
  validates :option, presence: true
  validates :survey_option_question_id, presence: true
  validates_inclusion_of :option_type,
                         in: %w(row column text image),
                         on: %i(create update),
                         message: "is invalid"
  validates_presence_of :position,
                        on: %i(create update),
                        message: "position is required",
                        if: -> { %w(row column).include?(option_type) }

  belongs_to :survey_option_question
  has_many :survey_section_rules, dependent: :destroy
end
