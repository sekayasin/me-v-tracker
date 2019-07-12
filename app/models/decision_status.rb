class DecisionStatus < ApplicationRecord
  has_many :decision_reason_statuses
  has_many :decision_reasons, through: :decision_reason_statuses

  def self.get_reasons(status)
    decision_status = includes(:decision_reasons).find_by(status: status)

    decision_status&.decision_reasons&.pluck(:reason)
  end

  def self.get_all_statuses
    pluck(:status)
  end
end
