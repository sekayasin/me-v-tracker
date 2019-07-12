class CreateSurvey < ActiveRecord::Migration[5.0]
  def change
    create_table :surveys, id: false do |t|
      t.string :survey_id, primary: true, index: true
      t.string :title
      t.string :link
      t.string :status, default: "Receiving Feedback"

      t.timestamps
    end
  end
end
