class RenameBootcamperDecisionReasonsToDecisions < ActiveRecord::Migration[5.0]
  def change
    rename_table :bootcamper_decision_reasons, :decisions
  end
end
