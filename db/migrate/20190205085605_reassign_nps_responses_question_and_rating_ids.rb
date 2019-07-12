class ReassignNpsResponsesQuestionAndRatingIds < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["db:reassign_nps_response_question_and_rating_ids"].invoke
  end
end
