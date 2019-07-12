class CreateScheduleFeedbacks < ActiveRecord::Migration[5.0]
    def change
      create_table :schedule_feedbacks do |t|
        t.string :cycle_center_id
        t.string :nps_question_id
        t.datetime :popup_time
  
        t.timestamps
      end
    end
  end
  