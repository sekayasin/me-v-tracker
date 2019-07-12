class AddNotificationGroupToNotificationsMessage < ActiveRecord::Migration[5.0]
  def change
    add_reference :notifications_messages, :notification_group, foreign_key: true
    Rake::Task['db:add_notification_group_id_to_notification_message_table'].invoke
  end
end
