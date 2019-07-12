class RemoveRatingsFromLearnersPitches < ActiveRecord::Migration[5.0]
  def change
    remove_column :learners_pitches, :ratings
  end
end
