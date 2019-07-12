class DecisionReasonStatus < ApplicationRecord
  belongs_to :decision_reason
  belongs_to :decision_status
end
