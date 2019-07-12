module ApplicationControllerHelper
  def send_broadcast(notification_info, message)
    notification_info[:recipient_emails].split(",").each do |email|
      notification = Notification.create!(
        recipient_email: email.strip,
        notifications_message_id: message.as_json["id"],
        is_read: "false"
      )

      ActionCable.server.broadcast(
        "notifications-" + email.strip,
        html: render_notification(
          id: notification.as_json["id"],
          content: notification_info[:content],
          priority: notification_info[:priority],
          group: notification_info[:group],
          created_at: notification.as_json["created_at"],
          is_read: "false"
        )
      )
    end
  end

  def save_learner_notification(notification_info)
    group = NotificationGroup.find_or_create_by(name: notification_info[:group])
    message = NotificationsMessage.create!(
      priority: notification_info[:priority],
      content: notification_info[:content],
      notification_group_id: group.id
    )
    send_broadcast(notification_info, message)
  end

  private

  def render_notification(notification)
    ApplicationController.render(
      partial: "layouts/notification",
      locals: { notification: notification }
    )
  end
end
