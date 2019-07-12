class CompleteSurveyJob < ApplicationJob
  queue_as :default

  def perform(id, date)
    survey = Survey.find(id)
    unless survey.blank?
      end_date = survey.end_date
      check_date = date.to_datetime
      if end_date == check_date
        survey.update(status: "Completed")
        SendSurveyBroadcastJob.perform_later(survey, "close")
      end
    end
  end
end
