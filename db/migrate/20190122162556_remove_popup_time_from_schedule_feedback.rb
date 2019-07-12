class RemovePopupTimeFromScheduleFeedback < ActiveRecord::Migration[5.0]
  def change
    remove_column :schedule_feedbacks, :popup_time, :datetime
  end
end
