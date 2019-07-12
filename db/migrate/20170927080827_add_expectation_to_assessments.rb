class AddExpectationToAssessments < ActiveRecord::Migration[5.0]
  def change
    add_column :assessments, :expectation, :text
  end
end
