class RemoveCriteriumIndexFromAssessment < ActiveRecord::Migration[5.0]
  def change
    remove_index :assessments, column: :criterium_id
  end
end
