//= require cable
//= require_self

(function() {
  $(document).ready(function() {
    window.surveys = new Survey.App();

    App.cable.subscriptions.create('FeedbackPopChannel', {
        received: function(feedback) {
          surveys.openFeedBackPopUp(feedback)
        }
    });
  });
}).call(this);
