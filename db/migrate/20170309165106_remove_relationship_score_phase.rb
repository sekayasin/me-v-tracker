class RemoveRelationshipScorePhase < ActiveRecord::Migration[5.0]
  def change
    remove_column :scores, :phase_id
  end
end
