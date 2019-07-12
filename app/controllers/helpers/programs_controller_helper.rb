module ProgramsControllerHelper
  def has_phases?
    if  params[:program][:program_id].blank? &&
        params[:program][:phases].blank?
      return false
    end

    true
  end

  def get_params
    if params[:program][:program_id].present?
      program = Program.program_details(params[:program][:program_id])
      params[:program].merge!(
        holistic_evaluation: program[:holistic_evaluation],
        cadence_id: program[:cadence_id],
        estimated_duration: program[:estimated_duration]
      )
    end

    program_params
  end

  def phase_ids
    if params[:program][:program_id].blank?
      params[:program][:phases].map! do |phase|
        phase.split.map(&:capitalize).join(" ")
      end
      Phase.find_or_create_phase(params[:program][:phases])
      Phase.where(name: params[:program][:phases]).pluck(:id)
    else
      Phase.clone_phases(Program.
                         where(id: params[:program][:program_id]).
                         includes(:phases).
                         pluck("phases.id"))
    end
  end

  def get_frameworks_details
    frameworks = Framework.
                 includes(criteria: :assessments).order(name: :desc).all
    @frameworks = frameworks.map do |framework|
      {
        id: framework.id,
        name: framework.name,
        criteria: framework.criteria.map do |criterium|
          assessments = criterium.assessments.pluck(:id, :name)
          next if assessments.empty?

          {
            id: criterium.id,
            name: criterium.name,
            assessments: assessments
          }
        end.compact!
      }
    end
  end

  def get_phases_details
    @program.phases.map do |phase|
      {
        id: phase.id,
        name: phase.name,
        phase_duration: phase.phase_duration,
        phase_decision_bridge: phase.phase_decision_bridge,
        assessments: phase.assessments.pluck(:id)
      }
    end
  end

  def get_program_cadence_id(holistic_evaluation)
    return nil unless holistic_evaluation

    holistic_evaluation.symbolize_keys!
    Cadence.find_or_create_by(
      name: holistic_evaluation[:cadence].symbolize_keys![:name],
      days: holistic_evaluation[:cadence].symbolize_keys![:days]
    ).id
  end

  def get_program_language_stacks
    DlcStack.where(program_id: params[:id]).pluck(:language_stack_id)
  end

  def update_program_phases_and_assessments
    @program_phases.each_with_index do |phase_details, index|
      phase_details.symbolize_keys!
      phase = Phase.update_or_create(phase_details)
      current_phase_assessments_ids = phase.assessments.pluck(:id)
      final_phase_assessments_ids = phase_details[:assessments]
      add_assessments_to_phase(
        current_phase_assessments_ids,
        final_phase_assessments_ids,
        phase
      )
      remove_assessments_from_phase(
        current_phase_assessments_ids,
        final_phase_assessments_ids,
        phase
      )
      ProgramsPhase.update_or_create(@program_id, phase.id, index + 1)
      phase_details[:id] = phase.id
    end
  end

  def add_assessments_to_phase(
    current_phase_assessments_ids,
    final_phase_assessments_ids,
    phase
  )
    final_phase_assessments_ids.each do |assessment_id|
      unless current_phase_assessments_ids.include?(assessment_id)
        phase.assessments << Assessment.find(assessment_id)
      end
    end
  end

  def remove_assessments_from_phase(
    current_phase_assessments_ids,
    final_phase_assessments_ids,
    phase
  )
    current_phase_assessments_ids.each do |assessment_id|
      unless final_phase_assessments_ids.include? assessment_id
        phase.assessments.delete(assessment_id)
      end
    end
  end

  def remove_old_program_phases
    ProgramsPhase.delete_all_except(@program_id, @program_phases)
  end

  def handle_program_language_stacks
    if @final_language_stacks.empty?
      DlcStack.where(program_id: @program_id).delete_all
    else
      create_or_update_language_stacks
    end
  end

  def create_or_update_language_stacks
    language_stacks = LanguageStack.all
    stacks_to_be_updated = []
    language_stack_ids = @final_language_stacks.map do |name|
      existing_stack = language_stacks.detect { |stack| name == stack.name }
      if existing_stack
        stacks_to_be_updated << existing_stack.id
        existing_stack.id
      else
        LanguageStack.create(name: name, dlc_stack_status: true).id
      end
    end
    LanguageStack.
      where(id: stacks_to_be_updated).update_all(dlc_stack_status: true)
    DlcStack.save_dlc_language(@program_id, language_stack_ids)
  end

  def gather_final_details(details, cadence_id)
    {
      name: details[:name],
      description: details[:description],
      estimated_duration: details[:estimated_duration],
      holistic_evaluation: !!details[:holistic_evaluation],
      cadence_id: cadence_id,
      save_status: true
    }
  end
end
