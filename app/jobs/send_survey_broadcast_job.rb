class SendSurveyBroadcastJob < ApplicationJob
  queue_as :default
  include SurveysControllerHelper

  def perform(survey, action)
    send_survey_broadcast(survey, action)
  end
end
