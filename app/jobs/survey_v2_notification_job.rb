class SurveyV2NotificationJob < ApplicationJob
  include ApplicationControllerHelper
  queue_as :default

  def perform(id, date, cycle_center)
    survey = NewSurvey.find(id)
    start_date = survey.start_date.to_datetime.to_i
    check_date = date.to_datetime.to_i
    if check_date == start_date
      send_survey_v2_notification(survey, cycle_center)
    end
  rescue ActiveRecord::RecordNotFound
  end

  def send_survey_v2_notification(survey, cycle_center)
    cycle_center = CycleCenter.find(cycle_center)
    emails = cycle_center.bootcampers.pluck(:email).join(",")
    notification_info = {
      recipient_emails: emails,
      group: "Survey",
      priority: "Normal",
      content:
          "Hello! You have received a new survey
        <a class='survey-link' href='/surveys-v2/respond/#{survey.id}'
          target='_blank' id='#{survey.id}'
        >
         <strong >
           #{survey['title']}
         </strong>
        </a>"
    }
    save_learner_notification(notification_info)
  end
end
