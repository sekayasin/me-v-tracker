class Framework < ApplicationRecord
  has_many :framework_criteria
  has_many :criteria, through: :framework_criteria
  has_many :assessments, through: :framework_criteria
  has_many :scores, through: :assessments
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true

  def average_score(learner_program_id, total_assessments)
    return 0.0 if total_assessments.zero?

    query_params = {
      learner_programs_id: learner_program_id,
      assessment_id: Assessment.get_framework_assessments(id).map(&:id)
    }
    total_score = Score.where(query_params).sum(:score)
    (total_score / total_assessments).round(1)
  end

  def get_assessments_count(framework_criterium_id)
    framework_assessments_count = 0

    Phase.all.includes(assessments: :framework_criterium).each do |phase|
      framework_assessments_count += phase.assessments.where(
        framework_criterium_id: framework_criterium_id
      ).count
    end
    framework_assessments_count
  end

  def self.get_program_frameworks(program_id)
    framework_ids = Program.joins(phases: { assessments: :framework }).
                    where(id: program_id).
                    select("frameworks.id").
                    distinct.pluck("frameworks.id")

    Framework.where(id: framework_ids)
  end
end
