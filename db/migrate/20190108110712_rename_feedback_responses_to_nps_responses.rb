class RenameFeedbackResponsesToNpsResponses < ActiveRecord::Migration[5.0]
  def change
    rename_table :feedback_responses, :nps_responses
  end
end
