class SurveyCollaboratorMailer < ApplicationMailer
  def invite_survey_collaborator(collaborator, survey_link, survey)
    attachments.inline["email-vof-logo.png"] =
      File.read("#{Rails.root}/app/assets/images/logos/email-vof-logo.png")
    @collaborator = collaborator.split("@")[0].sub(".", " ").titlecase
    @survey = survey
    @survey_link = survey_link
    mail to: collaborator
  end
end
