module FeedbackControllerHelper
  def populate_feedback(all_feedback)
    learner_feedback = []
    all_feedback.each do |feedback|
      feedback_details = {
        id: feedback.id,
        phase: feedback.phase.name,
        assessment: feedback.assessment.name,
        impression: feedback.impression.name,
        comment: feedback.comment,
        reflection: feedback.reflection,
        date: feedback.created_at
      }
      learner_feedback << feedback_details
    end
    learner_feedback
  end
end
