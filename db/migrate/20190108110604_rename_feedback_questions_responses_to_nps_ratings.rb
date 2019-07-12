class RenameFeedbackQuestionsResponsesToNpsRatings < ActiveRecord::Migration[5.0]
  def change
    rename_table :feedback_questions_responses, :nps_ratings
  end
end
