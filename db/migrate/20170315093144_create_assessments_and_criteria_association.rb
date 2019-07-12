class CreateAssessmentsAndCriteriaAssociation < ActiveRecord::Migration[5.0]
  def change
    add_reference :assessments, :criteria, index: true, foreign_key: true
  end
end
