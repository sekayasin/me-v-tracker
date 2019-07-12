class BootcamperFacade
  def initialize(update_params, learner_program = nil)
    @params = update_params
    @learner_program = learner_program if learner_program
    @learner_program_id = @learner_program.id if learner_program
  end

  def update_decision_reasons
    stage = @params[:decision_stage_reasons].keys.first.to_i
    reasons = @params[:decision_stage_reasons].values.first

    reasons_ids = DecisionReason.get_ids(reasons)
    Decision.save_reasons(
      @learner_program_id,
      stage,
      reasons_ids
    )
  end

  def create_bootcamper(valid_data)
    sanitized_data = []
    valid_data[0].each do |camper|
      camper[:first_name].capitalize!
      camper[:last_name].capitalize!
      sanitized_data << Bootcamper.validate_camper(camper)
    end
    permitted = %i(program_id dlc_stack_id week_one_facilitator
                   week_two_facilitator camper_id cycle_center)

    valid_data[1].each_with_index do |learner_program, index|
      cycle_center = CycleCenter.get_or_create_cycle_center(
        learner_program
      )

      week_one_lfa = Facilitator.find_or_create_by(
        email: learner_program[:week_one_lfa]
      )
      week_two_lfa = Facilitator.find_by_email("unassigned@andela.com")
      learner_program[:cycle_center] = cycle_center
      learner_program[:week_one_facilitator] = week_one_lfa
      learner_program[:week_two_facilitator] = week_two_lfa
      learner_program[:camper_id] = sanitized_data[index][:camper_id]
      LearnerProgram.create(
        learner_program.select { |lp| permitted.include? lp }
      )
    end
  end

  def get_lfa_and_status
    if @params.key?(:decision_one)
      Decision.delete_bootcamper_reasons(@learner_program_id)
      { status: { decision_one: @params[:decision_one] } }
    elsif @params.key?(:decision_two)
      Decision.delete_bootcamper_reasons(@learner_program_id, 2)
      { status: { decision_two: @params[:decision_two] } }
    elsif @params.key?(:week_one_lfa)
      { lfa: { week_one_facilitator_id: get_facilitator_id(
        @params[:week_one_lfa]
      ) } }
    elsif @params.key?(:week_two_lfa)
      { lfa: { week_two_facilitator_id: get_facilitator_id(
        @params[:week_two_lfa]
      ) } }
    end
  end

  def update_lfa_or_decision_status
    week_status = get_lfa_and_status

    if week_status.key?(:lfa)
      @learner_program.update(week_status[:lfa])
    elsif week_status.key?(:status)
      if %w(Advanced Fast-tracked).include? week_status[:status][:decision_one]
        week_status[:status][:decision_two] = "In Progress"
      end
      @learner_program.update(week_status[:status])
    end
  end

  def get_facilitator_id(email)
    Facilitator.find_by_email(email).id
  end
end
