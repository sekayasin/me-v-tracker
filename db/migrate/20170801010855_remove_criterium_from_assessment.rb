class RemoveCriteriumFromAssessment < ActiveRecord::Migration[5.0]
  def change
    remove_column :assessments, :criterium_id, :integer
  end
end
