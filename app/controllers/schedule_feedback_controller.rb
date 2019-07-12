class ScheduleFeedbackController < ProgramNpsController
  def save_feedback_schedule
    cycle_center = CycleCenter.find_by(
      center_id: schedule_data_params[:center_id],
      cycle_id: schedule_data_params[:cycle_id]
    )
    if cycle_center
      feedback_schedule = ScheduleFeedback.new(
        program_id: schedule_data_params[:program],
        cycle_center: cycle_center,
        nps_question_id: schedule_data_params[:nps_question_id],
        start_date: schedule_data_params[:start_date],
        end_date: schedule_data_params[:end_date]
      )
      if feedback_schedule.save
        render json: { saved: true, feedback_schedule: feedback_schedule }
      else
        render json: { saved: false, errors: "An error occured." }
      end
    else
      render json: { saved: false, errors: "Invalid cycle/center details" }
    end
  end

  private

  def schedule_data_params
    params.permit(
      :program,
      :cycle_id,
      :center_id,
      :nps_question_id,
      :start_date,
      :end_date
    )
  end
end
