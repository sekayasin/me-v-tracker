class ReflectionsController < ApplicationController
  skip_before_action :redirect_non_andelan
  before_action :get_feedback_reflection, only: %i[show update]

  def show
    render json: @reflection
  end

  def create
    @reflection = Reflection.new(reflection_params)
    if @reflection.save
      flash[:notice] = "reflection-success"
      learner_program = Bootcamper.find_by(
        email: session[:current_user_info][:email]
      ).learner_programs.last
      output = {
        reflection: @reflection,
        learner_programs_id: learner_program.id,
        lfa_email: learner_program.active_lfa.email,
        learner_name: learner_program.bootcamper.name,
        phase_name: @reflection.feedback.phase.name,
        output_name: @reflection.feedback.assessment.name,
        phase_id: @reflection.feedback.phase.id,
        assessment_id: @reflection.feedback.assessment.id
      }
      render json: output
    else
      flash[:error] = @reflection.errors.full_messages[0]
    end
  end

  def update
    if @reflection.update_attributes(comment: params[:comment])
      flash[:notice] = "update-success"
      render json: @reflection
    else
      flash[:error] = @reflection.errors.full_messages[0]
    end
  end

  private

  def reflection_params
    params.require(:reflection).permit(:comment, :feedback_id)
  end

  def get_feedback_reflection
    @reflection = Reflection.find_by_feedback_id(params[:feedback_id])
  end
end
