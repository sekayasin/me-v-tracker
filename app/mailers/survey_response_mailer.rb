class SurveyResponseMailer < ApplicationMailer
  def notify_unresponded_survey(bootcamper, survey)
    @bootcamper = bootcamper
    @survey = survey
    mail to: bootcamper.email
  end
end
