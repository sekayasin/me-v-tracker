class RenameAssociationTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :assessments_and_phases, :assessments_phases
    rename_table :criteria_and_assessments, :assessments_criteria
  end
end
