class ChangeFeedbackQuestionId < ActiveRecord::Migration[5.0]
  def change
    rename_column :nps_questions, :feedback_question_id, :nps_question_id
    rename_column :nps_ratings, :feedback_question_id, :nps_question_id
    Rake::Task['db:add_questions_to_nps_question_table'].invoke
  end
end
