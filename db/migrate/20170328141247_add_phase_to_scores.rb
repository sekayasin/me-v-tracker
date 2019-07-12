class AddPhaseToScores < ActiveRecord::Migration[5.0]
  def change
    add_reference :scores, :phase, index: true
  end
end
