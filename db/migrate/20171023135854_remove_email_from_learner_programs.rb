class RemoveEmailFromLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    remove_column :learner_programs, :email, :string
  end
end
