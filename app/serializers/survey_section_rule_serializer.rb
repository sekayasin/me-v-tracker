class SurveySectionRuleSerializer < ActiveModel::Serializer
  attributes :id, :survey_option_id, :survey_section_id
  belongs_to :survey_options
  belongs_to :survey_sections
end
