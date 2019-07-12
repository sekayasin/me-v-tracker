module ProgramNpsHelper
  def create_program_feedback_data
    @nps_question = create(:nps_question)
    @nps_response = create(:nps_rating)
    @learner_prog = create(:learner_program)
  end

  def clear_program_feedback_data
    @nps_question.destroy
    @nps_response.destroy
    @learner_prog.destroy
  end
end
