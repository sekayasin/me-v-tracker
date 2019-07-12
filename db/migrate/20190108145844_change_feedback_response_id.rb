class ChangeFeedbackResponseId < ActiveRecord::Migration[5.0]
  def change
    rename_column :nps_ratings, :feedback_response_id, :nps_response_id
    rename_column :nps_responses, :feedback_response_id, :nps_response_id
  end
end
