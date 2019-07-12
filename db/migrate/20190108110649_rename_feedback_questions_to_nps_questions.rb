class RenameFeedbackQuestionsToNpsQuestions < ActiveRecord::Migration[5.0]
  def change
    rename_table :feedback_questions, :nps_questions
  end
end
