class AddHolisticEvaluationAndCadenceIdToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :holistic_evaluation, :boolean
    add_reference :programs, :cadence, foreign_key: true
  end
end
