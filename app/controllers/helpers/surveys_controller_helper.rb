module SurveysControllerHelper
  def create_survey
    survey = Survey.create(survey_params)
    if survey.valid?
      survey_pivots = prepare_cycles_centers_pivots(survey.survey_id)
      SurveyPivot.create(survey_pivots)
      CompleteSurveyJob.set(wait_until: survey.end_date).
        perform_later(survey.id, survey.end_date.to_s)
    end
    survey
  end

  def update_survey
    @survey.update(survey_params)
    if @survey.valid?
      survey_pivots = prepare_cycles_centers_pivots(@survey.survey_id)
      SurveyPivot.where(survey_id: @survey.survey_id).delete_all
      SurveyPivot.create(survey_pivots)
      CompleteSurveyJob.set(wait_until: @survey.end_date).
        perform_later(@survey.id, @survey.end_date.to_s)
    end
    @survey
  end

  def prepare_cycles_centers_pivots(survey_id)
    cycle_centers = CycleCenter.where(cycle_center_id: params[:recipients])
    cycle_centers.map do |cycle_center|
      {
        survey_id: survey_id,
        surveyable: cycle_center
      }
    end
  end

  def close_survey
    survey = Survey.find_by(survey_id: params[:id])
    unless survey.blank?
      survey.update(status: "Completed")
    end
    survey
  end

  def send_survey_broadcast(survey, action)
    emails = get_emails(survey)
    emails.each do |email|
      content = { survey: survey, email: email, action: action }
      ActionCable.server.broadcast(
        "survey-" + email.strip, content
      )
    end
  end

  def get_emails(survey)
    cycle_centers = SurveyPivot.where(survey_id: survey.survey_id).
                    pluck(:surveyable_id)
    campers_emails = LearnerProgram.where(cycle_center_id: cycle_centers).
                     includes(:bootcamper).pluck(:email)
    admins = AdminService.new.admin_data
    admins_emails = admins.values[0].pluck("email")
    campers_emails + admins_emails
  end
end
