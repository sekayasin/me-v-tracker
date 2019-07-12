class SurveyOptionQuestion < ApplicationRecord
  validates :question_type, presence: true
  validates_inclusion_of :question_type, in: %w(
    SurveySelectQuestion
    SurveyCheckboxQuestion
    SurveyMultipleChoiceQuestion
    SurveyPictureOptionQuestion
    SurveyPictureCheckboxQuestion
    SurveyMultigridOptionQuestion
    SurveyMultigridCheckboxQuestion
  ), on: %i(create update), message: "is not a valid question type"

  has_many :survey_options, dependent: :destroy
  has_one :survey_question, as: :questionable, dependent: :destroy
end
