class RecreateDecisionStatuses < ActiveRecord::Migration[5.0]
  def change
    revert do
      create_table :decision_reason_statuses do |t|
        t.integer :decision_reason_id
        t.integer :decision_status_id
      end
    end
    create_table :decision_reason_statuses, id: false do |t|
      t.belongs_to :decision_reason, index: true
      t.belongs_to :decision_status, index: true
    end
  end
end
