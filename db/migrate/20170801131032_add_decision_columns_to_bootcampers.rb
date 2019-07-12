class AddDecisionColumnsToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :decision_one_comment, :text
    add_column :bootcampers, :decision_two_comment, :text
    add_column :bootcampers, :decision_one_reason_id, :integer
    add_column :bootcampers, :decision_two_reason_id, :integer
  end
end
