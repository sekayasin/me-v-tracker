//= require cable
//= require_self

(function() {

  $(document).ready(function() {
    window.notifications = new Notifications.App();

    App.notifications = App.cable.subscriptions.create('NotificationsChannel', {
        received: function(notification) {
          notifications.onReceiveNotification(notification);
        }
    });
  });
}).call(this);
