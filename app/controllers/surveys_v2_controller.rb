class SurveysV2Controller < LearnersParentController
  include BootcamperDataConcern
  include SurveysV2ControllerHelper

  def index
    unless helpers.admin? || helpers.authorized_learner?
      return redirect_to index_path
    end

    @surveys = fetch_surveys(helpers.admin?)
    respond_to do |format|
      format.json { render json: @surveys }
      format.html { render template: "surveys_v2/index" }
    end
  end

  def setup
    unless helpers.admin?
      redirect_to surveys_v2_path
    end
  end

  def create
    @question_data_map = {}
    survey_data = survey_params(params[:survey])
    survey = build_survey(survey_data[:survey])
    questions = build_questions(survey, survey_data)
    build_options(questions)
    build_section_rules(survey, survey_data)
    unless survey_data[:collaborators].nil?\
      || survey_data[:collaborators].empty?
      invite_collaborator(survey_data[:collaborators],
                          survey, survey_data[:program_id])
    end
  rescue SurveyException, SurveyQuestionException, SurveyOptionException => e
    Bugsnag.custom_notify(e)
    survey.destroy
  ensure
    if e
      render json: e.message, status: 400
    elsif survey.status == "published"
      cycle_centers = survey_data[:survey][:cycle_centers]
      send_notification_per_timezone(cycle_centers, survey)
      render json: { message: "Successfully created survey" }, status: 201
    else
      render json: { message: "Successfully saved draft" }, status: 201
    end
  end

  def get_recipients
    return unless helpers.admin?

    cycles_centers =
      CycleCenter.active.includes(%i(center cycle)).
      order("cycles_centers.created_at DESC").
      pluck(:cycle_center_id, :'centers.name', :'cycles.cycle').
      map do |cycle_center_id, name, cycle|
        { cycle_center_id: cycle_center_id, name: name, cycle: cycle }
      end
    render json: { recipients: cycles_centers }
  end

  def respond
    if helpers.authorized_learner?
      render template: "surveys_v2/respond"
    else
      redirect_to index_path
    end
  end

  def get_respondents
    email = session[:current_user_info][:email]
    respondent = Bootcamper.find_by_email(email).camper_id
    @responded_survey = SurveyResponse.where(
      "respondable_id = ?", respondent
    )
    render json: @responded_survey
  rescue NoMethodError
  end

  def survey_responses
    unless helpers.admin?
      return redirect_to index_path
    end

    @responses = SurveyResponse.where(new_survey_id: params[:id])
    @bootcampers = Bootcamper.where(
      camper_id: @responses.pluck(:respondable_id)
    ).pluck(:email, :first_name, :last_name, :camper_id)
    respond_to do |format|
      format.json do
        render json: { response: @responses, bootcampers: @bootcampers },
               include: %w[
                 survey_option_responses
                 survey_grid_option_responses
                 survey_date_responses
                 survey_time_responses
                 survey_paragraph_responses
                 survey_scale_responses
               ], status: 200
      end
      if helpers.admin?
        format.html { render template: "surveys_v2/responses" }
      else
        redirect_to index_path
      end
    end
  end

  def get_responses
    email = session[:current_user_info][:email].to_s
    @bootcamper = Bootcamper.find_by(email: email)
    @new_survey = NewSurvey.find(params[:survey_id])
    @survey_response = SurveyResponse.
                       where("new_survey_id = ? AND respondable_id = ? ",
                             params[:survey_id], @bootcamper[:camper_id])
    if @new_survey[:status] != "published"
      redirect_to "/surveys-v2"
    elsif !@new_survey[:edit_response] && !@survey_response.empty?
      redirect_to "/surveys-v2"
    else
      respond_to do |format|
        format.json do
          render json: @new_survey,
                 include: %w(survey_sections.survey_questions
                             survey_sections.survey_section_rules)
        end
        if helpers.authorized_learner? || helpers.admin?
          format.html { render template: "surveys_v2/respond" }
        else
          redirect_to index_path
        end
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    Bugsnag.custom_notify(e)
    redirect_to not_found_path
  end

  def clone_survey
    surveys = duplicate_survey(params[:survey_id])
    old_survey = surveys.first
    new_survey = surveys.last
    duplicate_survey_sections(old_survey, new_survey.id)
  rescue SurveyQuestionException, SurveyOptionException => e
    Bugsnag.custom_notify(e)
  rescue SurveyException, ActiveRecord::RecordNotFound => e
    Bugsnag.custom_notify(e)
    new_survey.destroy
  ensure
    if e
      render json: e.message, status: 400
    else
      render json: { message: "Survey was successfully cloned",
                     survey: new_survey }, status: 201
    end
  end

  def destroy
    new_survey = NewSurvey.find_by!(id: params[:id])
    new_survey.destroy
    render json: { message: "Survey deleted successfully" }, status: 200
  end

  def edit
    unless helpers.admin?
      return redirect_to index_path
    end

    @new_survey = NewSurvey.find(params[:survey_id])
    survey_creator = session[:current_user_info][:email]
    unless collaborator || @new_survey[:survey_creator] == survey_creator
      return redirect_to "/surveys-v2"
    end

    respond_to do |format|
      format.json do
        render json: @new_survey,
               include: %w(survey_sections.survey_questions
                           survey_sections.survey_section_rules)
      end
      format.html { render template: "surveys_v2/setup" }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to not_found_path
  end

  def show
    survey = NewSurvey.find(params[:id])
    respond_to do |format|
      format.json do
        render json: survey,
               include: %w(survey_sections.survey_questions
                           survey_sections.survey_section_rules)
      end
    end
  end

  def update_survey
    survey_id = JSON.parse(params[:survey])["survey_id"]
    survey_data = survey_params(params[:survey])
    @new_survey = NewSurvey.find(survey_id)
    @new_survey.update(survey_data[:survey].compact)
    begin
      SurveyResponse.find_by(new_survey_id: survey_id).destroy
    rescue NoMethodError
    end
    survey_sections = SurveySection.where(new_survey_id: @new_survey.id)
    survey_sections.each do |section|
      SurveyQuestion.where(survey_section_id: section.id).delete_all
      section.destroy
    end
    @question_data_map = {}
    questions = build_questions(@new_survey, survey_data)
    build_options(questions)
    build_section_rules(@new_survey, survey_data)
    invite_collaborator(survey_data[:collaborators],
                        @new_survey, survey_data[:program_id])
    render json: { message: "Successfully updated survey" }, status: 201
  rescue SurveyException, ActiveRecord::RecordNotFound => e
    render json: e.message, status: 404
  end

  def download_file
    download_media_object("#{params[:base_name]}.#{params[:extension]}")
  end

  def share_response
    survey_response_link = params[:url].split("/")
    survey_id = survey_response_link.last
    survey = NewSurvey.find(survey_id)
    params[:emails].each do |email|
      SurveyReportMailer.
        survey_report(email, params[:url], survey).deliver_now
    end
    render json: { message: "Successfully shared survey report" }, status: 200
  end

  def toggle_archive
    survey = NewSurvey.find(params[:survey_id])
    survey.status = params[:status]
    survey.save!
    if params[:status] == "archived"
      render json: { message: "Survey successfully put on hold" }, status: 200
    else
      render json: { message: "Successfully updated status
                     to #{params[:status]}" }, status: 200
    end
  end
end
