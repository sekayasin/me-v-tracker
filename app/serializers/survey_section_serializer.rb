class SurveySectionSerializer < ActiveModel::Serializer
  attributes :id, :position, :new_survey_id
  has_many :survey_questions
  has_many :survey_section_rules

  belongs_to :new_survey
end
