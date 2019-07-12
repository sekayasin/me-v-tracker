class NotificationPresenter < BasePresenter
  def day_text
    day = @model.notifications_message.created_at.localtime.strftime("%B %d")
    current_day = Date.today.strftime("%B %d")
    text = "Today" if day == current_day
    text = "Yesterday" if text.nil? && (day == Date.yesterday.day.to_s)
    text ||= day
    text
  end

  def time
    @model.notifications_message.created_at.localtime.strftime("%I:%M %p")
  end
end
