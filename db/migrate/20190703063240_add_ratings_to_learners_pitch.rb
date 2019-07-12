class AddRatingsToLearnersPitch < ActiveRecord::Migration[5.0]
  def change
    add_column :learners_pitches, :ratings, :string, :default => "not yet rated"
  end
end
