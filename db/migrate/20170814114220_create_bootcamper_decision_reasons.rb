class CreateBootcamperDecisionReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :bootcamper_decision_reasons do |t|
      t.string :camper_id
      t.integer :decision_one_reason_id
      t.integer :decision_two_reason_id
    end

    add_foreign_key :bootcamper_decision_reasons, :bootcampers, column: :camper_id, primary_key: :camper_id
  end
end
