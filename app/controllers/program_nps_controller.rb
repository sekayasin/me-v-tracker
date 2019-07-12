class ProgramNpsController < LearnersParentController
  include ProgramNpsControllerHelper

  def get_program_feedback_details
    cycle_center_data = {}
    active_cycle_centers = CycleCenter.active.includes(
      :center, :cycle
    ).group_by(&:program_id)
    active_cycle_centers.each do |program_id, cycle_centers|
      cycle_center_data[program_id] = {}
      cycle_centers.each do |cycle_center|
        center_id = cycle_center.center.center_id
        center_name = cycle_center.center.name
        cycles = [
          cycle_center.cycle.cycle_id,
          cycle_center.cycle.cycle,
          cycle_center.start_date,
          cycle_center.end_date
        ]
        program_center = cycle_center_data[program_id]
        create_center_data(program_center, center_name, center_id, cycles)
      end
    end

    @nps_questions = NpsQuestion.all
    data = {
      data: cycle_center_data,
      questions: @nps_questions
    }
    render json: data
  end

  def save_program_feedback
    if params.blank?
      return render json: {
        error: ["no feedback given"]
      }
    end
    render json: create_program_feedback(params)
  end

  private

  def create_center_data(program_center, center_name, center_id, cycles)
    program_center[center_id] = {} unless program_center.key? center_id
    program_center[center_id][:center_name] = center_name
    unless program_center[center_id].key? :cycles
      program_center[center_id][:cycles] = []
    end
    program_center[center_id][:cycles].push cycles
  end
end
