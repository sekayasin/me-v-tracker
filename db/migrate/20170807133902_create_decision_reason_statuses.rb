class CreateDecisionReasonStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :decision_reason_statuses do |t|
      t.integer :decision_reason_id
      t.integer :decision_status_id
    end
  end
end
