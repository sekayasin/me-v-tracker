class CreateFeedbackQuestionsResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_questions_responses, id: false do |t|
      t.string :fqr_id, primary: true, index: true
      t.string :feedback_response_id
      t.string :feedback_question_id
      t.string :cycle_center_id
      t.text :comment

      t.timestamps
    end
  end
end
