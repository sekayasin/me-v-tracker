class RemoveDecisionReasonsColumnsFromBootcamper < ActiveRecord::Migration[5.0]
  def change
    remove_column :bootcampers, :decision_one_reason_id, :integer
    remove_column :bootcampers, :decision_two_reason_id, :integer
  end
end
