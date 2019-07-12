module NotificationsHelper
  def current_user_notifications
    email = session[:current_user_info][:email]

    results = Notification.get_notifications(email, false)
    is_read = Notification.get_notifications(email, true)
    notification_count = 0
    results.each_value { |messages| notification_count += messages.length }
    [results: results,
     is_read: is_read,
     notification_count: notification_count]
  end

  def get_notification_day_text(notification_day)
    if notification_day.nil?
      return "Not Today"
    end

    day = notification_day.strftime("%B %d")
    current_day = Date.today.strftime("%B %d")
    text = "Today" if day == current_day
    text = "Yesterday" if text.nil? && (day == Date.yesterday.day.to_s)
    text ||= day
    time = notification_day.utc.localtime
    "#{text}, #{time.strftime('%I:%M %p')}"
  end
end
