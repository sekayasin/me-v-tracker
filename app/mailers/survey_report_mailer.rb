class SurveyReportMailer < ApplicationMailer
  def survey_report(email, survey_response_link, survey)
    attachments.inline["email-vof-logo.png"] =
      File.read("#{Rails.root}/app/assets/images/logos/email-vof-logo.png")
    @full_name = email.split("@")[0].sub(".", " ").titlecase
    @survey = survey
    @survey_response_link = survey_response_link
    mail to: email
  end
end
