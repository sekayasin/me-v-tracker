class RemoveCriteriumForeignKeyFromAssessment < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :assessments, column: :criterium_id
  end
end
