class CreateCriteriaAndAssessments < ActiveRecord::Migration[5.0]
  def change
    create_table :criteria_and_assessments do |t|
      t.belongs_to :assessment, index: true
      t.belongs_to :criterium, index: true
    end
  end
end
