class CreateDecisionStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :decision_statuses do |t|
      t.string :status
    end
  end
end
