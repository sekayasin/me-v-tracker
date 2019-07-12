class SurveyResponseMailerPreview < ActionMailer::Preview
  def notify_unresponded_survey
    SurveyResponseMailer.
      notify_unresponded_survey(Bootcamper.first, NewSurvey.first)
  end
end
