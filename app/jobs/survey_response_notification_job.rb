class SurveyResponseNotificationJob < ApplicationJob
  include ApplicationControllerHelper

  def perform
    surveys = NewSurvey.due_response
    CycleCenter.active.each do |cycle_center|
      cycle_center_surveys(cycle_center.id, surveys)
    end
  end

  private

  def cycle_center_surveys(cycle_center_id, surveys)
    surveys.each do |survey|
      bootcampers =
        Bootcamper.responded_to_survey_in_cycle(survey.id, cycle_center_id)
      notify_bootcampers(bootcampers, survey)
    end
  end

  def notify_bootcampers(bootcampers, survey)
    bootcampers.each do |bootcamper|
      email = bootcamper.email
      notification_info = {
        recipient_emails: email,
        group: "Survey Response",
        priority: "Normal",
        content: """
          Hello! #{bootcamper.first_name} Kindly respond to
          <a class='notification-link' href='/surveys-v2/respond/#{survey.id}'>
            #{survey.title}
          </a>
          as you have less than 24hrs before end date
        """
      }

      save_learner_notification(notification_info)
      SurveyResponseMailer.
        notify_unresponded_survey(bootcamper, survey).deliver_later
    end
  end
end
