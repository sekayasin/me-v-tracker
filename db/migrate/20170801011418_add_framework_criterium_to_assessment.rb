class AddFrameworkCriteriumToAssessment < ActiveRecord::Migration[5.0]
  def change
    add_reference :assessments, :framework_criterium, foreign_key: true
  end
end
