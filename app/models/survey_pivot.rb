class SurveyPivot < ApplicationRecord
  self.table_name = :surveys_pivots

  validates :survey_id, presence: true
  validates :surveyable_id, presence: true
  validates :surveyable_type, presence: true

  belongs_to :surveyable, polymorphic: true
  belongs_to :survey, foreign_key: :survey_id
end
