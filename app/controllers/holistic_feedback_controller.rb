class HolisticFeedbackController < ApplicationController
  def create
    feedback = params[:holistic_feedback].each_value do |value|
      HolisticFeedback.create!(
        comment: value[:comment],
        learner_program_id: params[:learner_program_id],
        criterium_id: value[:criterium_id]
      )
    end

    render json: { message: "success", data: feedback }
  end
end
