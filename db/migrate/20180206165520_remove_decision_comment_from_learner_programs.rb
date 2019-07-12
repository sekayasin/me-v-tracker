class RemoveDecisionCommentFromLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    remove_column :learner_programs, :decision_one_comment, :text
    remove_column :learner_programs, :decision_two_comment, :text
  end
end
