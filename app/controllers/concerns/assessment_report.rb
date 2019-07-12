module AssessmentReport
  extend ActiveSupport::Concern

  def group_assessments_by_framework(assessments)
    assessments.group_by do |assessment|
      assessment.framework_criterium.framework.name
    end
  end

  def group_assessments_by_criterium(assessments)
    assessments.group_by do |assessment|
      assessment.framework_criterium.criterium.name
    end
  end
end
