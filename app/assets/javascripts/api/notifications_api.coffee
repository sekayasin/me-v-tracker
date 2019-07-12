class Notifications.API
  clearNotifications: (ids) ->
    request = $.ajax(
        url: '/notifications/',
        type: 'DELETE'
        data: { notification_ids: ids }
      )

  createNotification: (params) =>
    request = $.ajax(
        url: '/notifications',
        type: 'POST',
        data: {
          content: params.content
          recipient_emails: params.recipient_emails
          priority: params.priority
          group: params.group
        }
      )