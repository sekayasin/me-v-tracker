class AddPhaseDecisionBridgeToPhase < ActiveRecord::Migration[5.0]
  def change
    add_column :phases, :phase_decision_bridge, :boolean, :default => false
  end
end
