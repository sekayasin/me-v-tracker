class NewSurveyCollaborator < ApplicationRecord
  belongs_to :new_survey
  belongs_to :collaborator
  validates :collaborator_id, presence: true
  validates :new_survey_id, presence: true
end
