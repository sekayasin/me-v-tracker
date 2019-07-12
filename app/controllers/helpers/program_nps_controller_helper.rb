module ProgramNpsControllerHelper
  def create_program_feedback(feedback_params)
    learner_program = LearnerProgram.
                      includes(:bootcamper).
                      find_by(id: feedback_params[:program])
    return unless learner_program.bootcamper.email ==
                  session[:current_user_info][:email]

    nps_question = NpsQuestion.find_by(
      question: feedback_params[:question]
    )
    nps_rating = NpsRating.find_by(
      rating: feedback_params[:rating].to_i
    )
    NpsResponse.create!(
      nps_question_id: nps_question.nps_question_id,
      nps_ratings_id: nps_rating ? nps_rating.nps_ratings_id : nil,
      cycle_center_id: learner_program.cycle_center_id,
      comment: feedback_params[:comment] || "",
      camper_id: learner_program.camper_id,
      learner_program_id: learner_program.id
    )
  end

  def bootcamper_data
    query = %i(bootcamper cycle_center program)
    bootcamper_program(query).first
  end
end
