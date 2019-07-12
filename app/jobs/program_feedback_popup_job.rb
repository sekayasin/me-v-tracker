class ProgramFeedbackPopupJob < ApplicationJob
  include ProgramNpsControllerHelper
  include ApplicationControllerHelper
  queue_as :default

  def perform
    scheduled_feedbacks = ScheduleFeedback.active
    scheduled_feedbacks.each do |scheduled_feedback|
      cycle_center_id = scheduled_feedback.cycle_center_id
      next unless CycleCenter.active?(cycle_center_id)

      nps_question_id = scheduled_feedback.nps_question_id
      question = NpsQuestion.find_by(nps_question_id: nps_question_id)
      learner_programs = LearnerProgram.
                         includes(:bootcamper).
                         where(cycle_center_id: cycle_center_id)
      show_feedback_pop(question, learner_programs)
    end
  end

  def show_feedback_pop(question, learner_programs)
    learner_programs.each do |learner_program|
      response = NpsResponse.where(
        nps_question_id: question.nps_question_id,
        camper_id: learner_program.bootcamper.camper_id,
        cycle_center_id: learner_program.cycle_center_id,
        learner_program_id: learner_program.id
      )
      next unless response.empty?

      ActionCable.server.broadcast(
        "feedback-pop-#{learner_program.bootcamper.email}",
        question: question.question,
        learner_program: learner_program.id
      )
    end
  end
end
