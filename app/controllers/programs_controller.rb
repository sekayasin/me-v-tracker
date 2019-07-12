class ProgramsController < ApplicationController
  before_action :admin?, only: %i[create edit update edit_details]
  include ProgramsControllerHelper

  def index
    if helpers.admin?
      programs = RedisService.get("programspage:all-programs")
      unless programs
        programs = Program.all.
                   includes(:dlc_stacks, :language_stacks, :programs_phase,
                            :phases).
                   references(:program_phases).
                   order("programs.created_at desc").
                   as_json(include: { language_stacks: { only: :name },
                                      phases: { only: :name } })
        RedisService.set("programspage:all-programs", programs)
      end
      respond_to do |format|
        format.html
        format.json { render_programs_as_json programs }
      end
    else
      redirect_non_admin
    end
  end

  def edit
    if Program.find(params[:id]).save_status
      redirect_to "/programs"
    else
      @assessment = Assessment.new
      get_frameworks_details
    end
  end

  def create
    @program = Program.new(get_params)

    if has_phases? && @program.save
      set_phases @program.id
      set_stacks @program.id
      render json: { program: @program }
    else
      error = @program.errors.full_messages[0]
      error ||= "Phases cannot be blank!"

      render json: { error: error }
    end
  end

  def edit_details
    @program = Program.joins(:phases).find(params[:id])
    render json: {
      name: @program.name,
      description: @program.description,
      holistic_evaluation: @program.holistic_evaluation,
      program_language_stacks: get_program_language_stacks,
      all_language_stacks: LanguageStack.all.pluck(:id, :name),
      phases: get_phases_details
    }
  end

  def update
    details = JSON.parse(params[:details]).symbolize_keys
    @program_id = details[:id]
    @program_phases = details[:phases]
    @final_language_stacks = details[:language_stacks]
    update_program_phases_and_assessments
    remove_old_program_phases
    handle_program_language_stacks
    cadence_id = get_program_cadence_id(details[:holistic_evaluation]) ||
                 Program.find(@program_id).cadence_id

    program = Program.
              update(@program_id, gather_final_details(details, cadence_id))
    render json: { saved: program.errors.empty?, program: program }
  end

  def get_program
    @program = Program.find(params[:id])
    if @program
      respond_to do |format|
        format.js
        format.html
        format.json { render json: @program }
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to not_found_path
  end

  def get_program_assessments
    program = Program.find_by(id: params[:program_id])
    if program
      program_data = RedisService.
                     get "programspage:program-assessments-#{program.id}"
      unless program_data
        program_data = { duration: program.estimated_duration,
                         language_stack: program.language_stacks }.merge(
                           program.assessment_options
                         )

        RedisService.
          set("programspage:program-assessments-#{program.id}", program_data)
      end
    else
      program_data = { error: "Program was not found" }
    end
    render json: program_data
  end

  private

  def redirect_non_admin
    respond_to do |format|
      format.html { redirect_to index_path }
      format.json do
        render json: {
          errors: "You are not authorized to view this resource", status: 401
        }
      end
    end
  end

  def render_programs_as_json(programs)
    programs_count = programs.size
    programs = Kaminari.paginate_array(programs).page(page_params[:page]).
               per(page_params[:size])
    render json: {
      programs_count: programs_count,
      paginated_data: programs
    }
  end

  def page_params
    params[:size] = 10 if params[:size].nil?
    params[:page] = 1 if params[:page].nil?
    { size: params[:size], page: params[:page] }
  end

  def program_params
    params.require(:program).permit(
      :name,
      :description,
      :holistic_evaluation,
      :cadence_id,
      :phases,
      :estimated_duration
    )
  end

  def set_phases(program_id)
    phase_ids.each do |phase_id|
      @program_phases = ProgramsPhase.
                        new(
                          program_id: program_id,
                          phase_id: phase_id
                        )
      @program_phases.save
    end
  end

  def set_stacks(program_id)
    DlcStack.copy_dlc_stacks(params[:program][:program_id], program_id)
  end

  def admin?
    redirect_to content_management_path unless helpers.admin?
  end
end
