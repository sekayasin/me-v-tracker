class CreateDecisionReason < ActiveRecord::Migration[5.0]
  def change
    create_table :decision_reasons do |t|
      t.string :reason
    end
  end
end
