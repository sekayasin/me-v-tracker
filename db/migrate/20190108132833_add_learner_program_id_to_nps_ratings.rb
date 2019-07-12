class AddLearnerProgramIdToNpsRatings < ActiveRecord::Migration[5.0]
  def change
    add_column :nps_ratings, :learner_program_id, :string
    add_index :nps_ratings, :learner_program_id
  end
end
