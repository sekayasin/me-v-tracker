//= require cable
//= require_self

(function() {
  $(document).ready(function() {
    window.surveys = new Survey.App();

    App.cable.subscriptions.create('SurveysChannel', {
        received: function(survey) {
          surveys.onReceiveSurvey(survey);
        }
    });
  });
}).call(this);
