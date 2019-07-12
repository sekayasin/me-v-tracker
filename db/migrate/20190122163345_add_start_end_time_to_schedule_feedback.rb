class AddStartEndTimeToScheduleFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :schedule_feedbacks, :start_date, :datetime
    add_column :schedule_feedbacks, :end_date, :datetime
    add_column :schedule_feedbacks, :program_id, :integer
  end
end
