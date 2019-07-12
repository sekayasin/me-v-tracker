namespace :app do
  desc "Updates all the notification links in our database"
  task update_notification_links: :environment do
    notifications = NotificationsMessage.all
    notifications.each(&method(:prepend_notification_classname))
  end
end

def get_notification_classname(notification_group_id)
  classname_list = {
    '1': "assignedLearner-notification-link",
    '2': "newprogram-notification-link",
    '3': "finalprogram-notification-link",
    '4': "submission-notification-link",
    '5': "overdue-submission-notification-link",
    '6': "learnerFeedback-notification-link",
    '7': "learnerReflection-notification-link"
  }
  classname_list[:"#{notification_group_id}"]
end

def prepend_notification_classname(notification)
  temp_container = []
  classname = get_notification_classname(notification.notification_group_id)
  return if notification.content.to_s.split("='", 2)[1].nil?

  temp_container.push(notification.content.to_s.split("='", 2))
  temp_container[0][1].prepend("#{classname} ")
  joined_notification = temp_container[0].join("='")

  notification.update!(
    content: joined_notification
  )
  temp_container.pop
end
