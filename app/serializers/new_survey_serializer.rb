class NewSurveySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :edit_response,
             :survey_responses_count, :end_date, :start_date,
             :recipients, :cycle_centers, :collaborators
  has_many :survey_sections

  def recipients
    object.cycle_centers.map do |cycle_center|
      {
        cycle: cycle_center.cycle.cycle,
        name: cycle_center.center.name,
        cycle_center_id: cycle_center.cycle_center_id
      }
    end
  end
end
