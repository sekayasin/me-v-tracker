module NotificationFrameworkHelpers
  def set_up
    @notification_group = create_list(:notification_group, 3)
    @notification_group.each do |group|
      @notifications_message = create(:notifications_message,
                                      notification_group_id:
                                      group.id,
                                      priority: %w[Urgent Normal].sample)
      @notification = Notification.create!(
        recipient_email: "oluwatomi.duyile@andela.com",
        is_read: false,
        notifications_message_id: @notifications_message.id
      )
    end
  end

  def tear_down
    Notification.delete_all
    NotificationsMessage.delete_all
  end
end
