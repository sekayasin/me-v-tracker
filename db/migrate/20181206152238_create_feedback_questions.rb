class CreateFeedbackQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_questions, id: false do |t|
      t.string :feedback_question_id, primary: true, index: true
      t.text :question
      t.integer :week

      t.timestamps
    end
  end
end
