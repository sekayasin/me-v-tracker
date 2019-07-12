class AddDeletedAtToAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :assessments, :deleted_at, :datetime
    add_index :assessments, :deleted_at
  end
end
