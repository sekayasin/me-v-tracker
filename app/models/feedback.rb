class Feedback < ApplicationRecord
  belongs_to :learner_program
  belongs_to :phase
  belongs_to :output_submission
  belongs_to :assessment, -> { with_deleted }
  belongs_to :impression
  has_one :reflection
  validates_presence_of :learner_program_id,
                        :phase_id,
                        :assessment_id,
                        :impression_id,
                        :comment

  self.table_name = "feedback"

  def self.create_or_update(feedback_details)
    feedback = Feedback.find_or_create_by(
      learner_program_id: feedback_details[:learner_program_id],
      phase_id: feedback_details[:phase_id],
      assessment_id: feedback_details[:assessment_id],
      output_submissions_id: feedback_details[:output_submissions_id]
    )
    feedback.update_attributes(
      impression_id: feedback_details[:impression_id],
      comment: feedback_details[:comment],
      finalized: feedback_details[:finalized]
    )
    feedback
  end

  def self.find_learner_feedback(output_params)
    Feedback.where(
      learner_program_id: output_params[:learner_program_id],
      phase_id: output_params[:phase_id],
      assessment_id: output_params[:assessment_id],
      output_submissions_id: output_params[:output_submissions_id]
    ).last
  end

  def self.find_learner_feedbacks(output_params)
    Feedback.where(
      learner_program_id: output_params[:learner_program_id],
      phase_id: output_params[:phase_id],
      assessment_id: output_params[:assessment_id]
    )
  end
end
