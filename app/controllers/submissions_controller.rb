class SubmissionsController < ApplicationController
  include SubmissionsControllerHelper
  include LearnersControllerHelper
  include AssessmentsControllerHelper

  def index
    email = session[:current_user_info][:email]
    lfa = Facilitator.where(email: email).any?
    unless admin? || lfa
      return redirect_to not_found_path
    end
  end

  def get_submissions
    email = session[:current_user_info][:email]
    lfa = Facilitator.find_by(email: email)

    key = "submissionspage:submissions-#{email}"
    if admin? && params.key?(:filters)
      learner_program_query = build_learner_program_query(params[:filters])
      key = "submissionspage:submissions-#{learner_program_query}"
    end

    learners_data = RedisService.get(key) if lfa
    learners_data ||= get_learners_data(lfa, key)
    render json: {
      paginated_data: Kaminari.
        paginate_array(learners_data).
        page(params[:page]).
        per(params[:size]),
      submissions_count: learners_data.size
    }
  end

  def get_learner_assessments_by_phases
    learner_program_id = params[:learner_program_id]
    learner_program = LearnerProgram.
                      includes(:bootcamper, :program, :cycle_center).
                      find_by(id: learner_program_id)

    program = Program.joins(:phases).find(learner_program.program_id)
    phases_assessment = generate_phase_assessments(program, learner_program)
    learner = {
      learner: learner_program.bootcamper.name,
      learner_program_id: learner_program_id
    }
    phases_assessment << learner
    render json: phases_assessment
  end

  def get_learner_submissions
    lfa_email = session[:current_user_info][:email]

    learner_program = LearnerProgram.
                      includes(:cycle_center,
                               :week_one_facilitator,
                               :week_two_facilitator).
                      find_by(id: params[:learner_program_id])
    if learner_program.nil?
      redirect_to not_found_path
      return
    end

    unless admin? || lfa_authorized?(lfa_email, learner_program)
      flash[:error] = "You are not authorized to view this page"
      redirect_to submissions_path
      return
    end

    if @frameworks.nil?
      @frameworks = Framework.order(name: :desc).
                    pluck(:id, :name)
    end
    render :learner_submissions
  end

  def get_learner_output
    @unique_assessment = Assessment.find(params[:assessment_id])
    learner_program_id = params[:learner_program_id]
    assessment_id = params[:assessment_id]
    output = OutputSubmission.
             includes(:learner_program, :submission_phase).
             where(
               learner_programs: { id: learner_program_id },
               assessment_id: assessment_id
             )
    present_phases
    render json: { outputs: output,
                   is_multiple: !@submissions_per_day.empty?,
                   submission_phases: @submissions_per_day }
  end

  def download_output
    file_name_id = params[:file_name_id]
    bucket = GcpService::LEARNER_SUBMISSIONS_BUCKET
    image = GcpService.download(bucket, file_name_id)
    send_data image.body
  end

  def get_cycles
    cycles = CycleCenter.
             includes(:center, :cycle).
             select("cycles.cycle").distinct.active.
             where("centers.name IN (?)", params[:centers]).
             references(:center).
             pluck(:cycle, :cycle_id, :name)
    render json: cycles
  end

  def get_facilitators
    lfas = LearnerProgram.where(
      centers: { name: params[:location] },
      cycles: { cycle_id: params[:cycle] }
    ).
           joins(cycle_center: :center).
           joins(cycle_center: :cycle).
           references(:week_one_facilitator, :week_two_facilitator).active
    facilitators = {
      week_one: lfas.map(&:week_one_facilitator).to_set.to_a.pluck(:email, :id),
      week_two: lfas.map(&:week_two_facilitator).to_set.to_a.pluck(:email, :id)
    }
    render json: facilitators
  end

  def get_center_params
    centers = Center.pluck(:name).uniq
    render json: {
      centers: centers
    }
  end

  private

  def admin?
    session[:current_user_info][:admin]
  end

  def get_learners(lfa)
    if admin? && params.key?(:filters)
      learner_program_query = build_learner_program_query(params[:filters])
      learners = LearnerProgram.
                 includes(learner_program_query[:query_includes]).
                 references(learner_program_query[:query_references]).
                 order("bootcampers.first_name").
                 where(learner_program_query[:query_where].
                join(" AND "),
                       *learner_program_query[:query_where_placeholders]).active
    else
      learners = LearnerProgram.includes(
        %i(bootcamper output_submissions feedback week_one_facilitator
           week_two_facilitator)
      ).order("bootcampers.first_name").active
      learners = learners.select { |learner| learner.active_lfa == lfa } if lfa
    end
    learners.select { |learner| learner.active_learner?(learner) }
  end

  def get_learners_data(lfa, key)
    learners = get_learners(lfa) if lfa || admin?
    if learners
      learners = get_learner_submissions_data(learners)
      RedisService.set(key, learners)
    else
      learners = []
    end
    learners
  end
end
