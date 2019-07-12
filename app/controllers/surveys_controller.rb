class SurveysController < LearnersParentController
  before_action :set_survey, only: [:update]
  include BootcamperDataConcern
  include SurveysControllerHelper
  before_action :prepare_survey_data, only: %i[get_surveys]

  def index
    if helpers.admin? || helpers.authorized_learner?
      surveys = get_surveys
      respond_to do |format|
        format.json { render json: surveys }
        format.html { render template: "surveys/index" }
      end
    else
      redirect_to index_path
    end
  end

  def get_surveys
    if helpers.admin?
      get_admin_surveys
    elsif helpers.authorized_learner?
      get_learner_surveys
    end
  end

  def create
    return if check_recipients

    survey = create_survey
    send_response(survey, "create")
  end

  def check_recipients
    if params[:recipients].blank? || params[:recipients].empty?
      render json: {
        saved: false, errors: { recipients: ["must be provided"] }
      }
    end
  end

  def update
    survey = update_survey
    send_response(survey, "update")
  end

  def close
    survey = close_survey
    if survey.blank?
      return render json: { saved: false, errors: "Survey not found" }
    end

    SendSurveyBroadcastJob.perform_later(survey, "close")
    render json: { saved: true, survey: survey }
  end

  def destroy
    survey = Survey.find_by(survey_id: params[:id])
    survey.destroy
    render json: {
      message: "Survey has been deleted successfully",
      id: params[:id], archived: true
    }
  end

  def get_selected_recipients
    center_ids = Survey.includes(:surveys_pivots).
                 where(survey_id: params[:id]).
                 pluck(:surveyable_id)
    cycles_centers = CycleCenter.includes(%i(center cycle)).
                     where(cycle_center_id: center_ids)
    render_cycles_centers_as_json cycles_centers
  end

  def get_recipients
    cycles_centers = CycleCenter.includes(%i(center cycle))
    render_cycles_centers_as_json cycles_centers
  end

  private

  def send_response(survey, action)
    if survey.valid?
      SendSurveyBroadcastJob.perform_later(survey, action)
      render json: { saved: true, survey: survey }
    else
      render json: { saved: false, errors: survey.errors }
    end
  end

  def get_admin_surveys
    query = { surveys_pivots: { surveyable_type: "CycleCenter" } }
    prepare_surveys(query)
  end

  def get_learner_surveys
    cycle_center_id = bootcamper_program(%i(bootcamper cycle_center)).
                      pluck(:cycle_center_id)
    query = {
      surveys_pivots: {
        surveyable_type: "CycleCenter",
        surveyable_id: cycle_center_id
      }
    }

    prepare_surveys(query)
  end

  def render_cycles_centers_as_json(cycle_centers)
    cycles_centers =
      cycle_centers.order("cycles_centers.created_at DESC").
      pluck(:cycle_center_id, :name, :cycle).
      map do |cycle_center_id, name, cycle|
        { cycle_center_id: cycle_center_id, name: name, cycle: cycle }
      end
    render json: { recipients: cycles_centers } if helpers.admin?
  end

  def prepare_surveys(query)
    surveys = Survey.includes(:surveys_pivots).
              where(query).
              distinct("surveys_pivots.survey_id").
              order("surveys.created_at DESC")
    surveys = paginated_surveys(surveys)

    { admin: helpers.admin?, paginated_data: surveys,
      total_pages: surveys.total_pages, current_page: surveys.current_page,
      surveys_count: surveys.total_count }
  end

  def paginated_surveys(surveys)
    page = params[:page].nil? ? 1 : params[:page]
    size = params[:size].nil? ? 10 : params[:size]
    Kaminari.paginate_array(surveys).
      page(page).
      per(size)
  end

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:link, :title, :start_date, :end_date)
  end
end
