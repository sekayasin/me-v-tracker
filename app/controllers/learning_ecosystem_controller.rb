class LearningEcosystemController < ApplicationController
  before_action :redirect_unauthorized_learner,
                only: %i(index get_learner_ecosystem_phases)
  skip_before_action :redirect_non_andelan

  include LearnersControllerHelper
  include LearningEcosystemControllerHelper
  include AssessmentsControllerHelper

  def index
    @frameworks = Framework.order(name: :desc).pluck(:id, :name)
    program = get_program
    @phases_summary = RedisService.get("learning_ecosystem:phases_summary")
    if @phases_summary
      @phases_summary.map(&:deep_symbolize_keys!)
    else
      @phases_summary
    end
    unless @phases_summary
      @phases_summary = get_phases_overview_details
      RedisService.set("learning_ecosystem:phases_summary", @phases_summary)
    end
    @weeks_count = @phases_summary.size
    @phases_count = program_phases_exist.size
    @outputs_count = get_total_required_submissions(program)
  end

  def get_learner_ecosystem_phases
    query = [:cycle_center]
    program = get_program(query)
    phases = generate_phase_assessments(program, @learner_program)
    render json: phases
  end

  def get_total_required_submissions(program)
    program_phases = program_phases_exist
    total_submissions = RedisService.
                        get("learning_ecosystem.#{program.try :id}")
    unless total_submissions
      total_submissions = Assessment.
                          get_required_submissions_count(program_phases)
      RedisService.
        set("learning_ecosystem.#{program.try :id}", total_submissions)
    end
    total_submissions
  end

  def get_program(query = [])
    @learner_program = get_learner_latest_learner_program(query)
    Program.joins(:phases).find_by_id(@learner_program.program_id)
  end

  def program_phases_exist
    program = get_program
    program.try(:phases) ? program.phases : []
  end

  def get_phases_overview_details
    program_phases = program_phases_exist
    group_phases(program_phases, @learner_program.id)
  end

  def get_learner_outputs
    @unique_assessment = Assessment.find(params[:assessmentId])
    learner = Bootcamper.find_by(email: session[:current_user_info][:email])
    learner_program = LearnerProgram.get_latest_learner_program(
      learner.camper_id
    )
    outputs = OutputSubmission.
              includes(:learner_program, :submission_phase).
              where(
                learner_programs: { id: learner_program.id },
                assessment_id: @unique_assessment.id
              )
    present_phases
    render json: { outputs: outputs,
                   submission_phases: @submissions_per_day,
                   is_multiple: !@submissions_per_day.empty? }
  end
end
