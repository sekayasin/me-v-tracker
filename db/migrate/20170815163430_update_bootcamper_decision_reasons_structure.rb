class UpdateBootcamperDecisionReasonsStructure < ActiveRecord::Migration[5.0]
  def change
    rename_column :bootcamper_decision_reasons, :decision_one_reason_id, :decision_stage
    rename_column :bootcamper_decision_reasons, :decision_two_reason_id, :decision_reason_id
    add_foreign_key :bootcamper_decision_reasons, :decision_reasons, column: :decision_reason_id, primary_key: :id
  end
end
