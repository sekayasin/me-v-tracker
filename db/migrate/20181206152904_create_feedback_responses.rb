class CreateFeedbackResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_responses, id: false do |t|
      t.string :feedback_response_id, primary: true, index: true
      t.integer :rating

      t.timestamps
    end
  end
end
