class DecisionReason < ApplicationRecord
  has_many :decisions,
           class_name: "Decision",
           foreign_key: "decision_reason_id"

  has_many :learner_programs,
           class_name: "LearnerProgram",
           foreign_key: "decision_reason_id",
           through: "decisions"

  has_many :decision_reason_statuses

  has_many :decision_statuses, through: :decision_reason_statuses

  validates :reason, presence: true, uniqueness: { case_sensitive: false }

  def self.get_ids(reasons)
    reasons = DecisionReason.where(reason: reasons)
    unless reasons.empty?
      reasons.pluck(:id)
    end
  end
end
