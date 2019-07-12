class AddDescriptionToAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :assessments, :description, :text
  end
end
