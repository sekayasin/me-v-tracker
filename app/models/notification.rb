class Notification < ApplicationRecord
  belongs_to :notifications_message

  def self.get_notifications(email, is_read)
    order_by = is_read ? "updated_at DESC" : "created_at DESC"
    notifications = includes(:notifications_message,
                             notifications_message: [:notification_group]).
                    where(recipient_email: email, is_read: is_read).
                    order(order_by).
                    group_by do |notification|
      notification.notifications_message.notification_group[:name]
    end
    notifications.sort.to_h
  end

  def self.update_notifications(ids)
    where("id IN (?)", ids).each do |notice|
      notice.is_read ? notice.delete : notice.update(is_read: true)
    end
  end
end
