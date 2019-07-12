class Collaborator < ApplicationRecord
  has_many :new_surveys, through: :new_survey_collaborators, dependent: :destroy
  has_many :new_survey_collaborators, dependent: :destroy
  validates :email, presence: true
end
