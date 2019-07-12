class BootcampersController < ApplicationController
  before_action :set_learner, only: %i[add update]
  include BootcampersHelper
  include BootcampersControllerHelper

  def index
    redirect_non_admin
  end

  def add
    data = learner_info
    if valid_data = validate_spreadsheet(data[2], data)
      BootcamperFacade.new(params).create_bootcamper(valid_data)
      invite_learners valid_data
      lfa_learner_list = filter_camper_lfa(valid_data)
      render json: [@existing_users, lfa_learner_list]
    else
      render json: @error
    end
  end

  def edit; end

  def show; end

  def validate_spreadsheet(sheet, data)
    @error = {}
    data = sheet.validate_spreadsheet(data)
    if data[:error]
      @error = data
    else
      @error[:error] = false
      @existing_users = data[:existing] unless data[:existing].empty?
    end
    check_nil(data[:bootcampers], data[:learner_programs])
  end

  def get_learners
    center = Center.find_by(
      name: params[:name]
    )
    cycle_center = CycleCenter.ongoing_bootcamp(center[:center_id])

    unless cycle_center
      return render json: {
        message: "No ongoing bootcamp at this location."
      }, status: 400
    end

    learner_programs = LearnerProgram.where(
      cycle_center_id: cycle_center[:cycle_center_id]
    ).includes("bootcamper")

    learners = learner_programs.map(&:bootcamper)
    render json: { learners: learners, learner_programs: learner_programs }
  end

  def update_lfa
    facilitator = Facilitator.find_or_create_by(email: params[:lfaEmail].strip)
    params[:selectedLearners].each do |learner_id|
      learner_program = LearnerProgram.get_latest_learner_program(learner_id)
      update_options = if params[:week] == "Week 1"
                         { week_one_facilitator_id: facilitator.id }
                       else
                         { week_two_facilitator_id: facilitator.id }
                       end

      learner_program.update(update_options)
    end

    render json: { message: "Facilitator update successful." }
  end

  def update
    return unless helpers.admin?

    BootcamperFacade.new(params, @learner).update_lfa_or_decision_status
    respond_to do |format|
      format.json { render json: { message: "status update successful" } }
    end
  end

  private

  def set_learner
    @learner = LearnerProgram.find_by_id(params[:learner_program_id])
  end

  def bootcampers_params
    params.permit(
      "country",
      "city",
      "cycle",
      "file",
      "program_id",
      "start_date",
      "end_date",
      "dlc_stack_id"
    )
  end

  def filter_camper_lfa(valid_data)
    lfa_learner_list = []
    valid_data[0].each_with_index do |camper, index|
      lfa_learner_list << {
        lfa: valid_data[1][index][:week_one_facilitator].email,
        learner: "#{camper[:first_name]} #{camper[:last_name]}",
        camper_id: valid_data[1][index][:camper_id],
        learner_program_id:
          learner_program_id(get_learner_program(valid_data[1][index]))
      }
    end

    lfa_learner_list
  end

  def get_learner_program(camper)
    LearnerProgram.get_latest_learner_program(camper[:camper_id])
  end

  def learner_program_id(learner_program)
    learner_program[:id] if learner_program
  end
end
