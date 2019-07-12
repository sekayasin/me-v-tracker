class RemovePhaseIdFromPhases < ActiveRecord::Migration[5.0]
  def change
    remove_column :assessments, :phase_id
  end
end
