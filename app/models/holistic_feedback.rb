class HolisticFeedback < ApplicationRecord
  belongs_to :learner_program
  belongs_to :criterium, -> { with_deleted }

  validates_presence_of :learner_program_id,
                        :criterium_id,
                        :comment

  self.table_name = "holistic_feedback"

  def self.create(feedback_details)
    create(
      comment: feedback_details[:comment],
      learner_program_id: feedback_details[:learner_program_id],
      criterium_id: feedback_details[:criterium_id]
    )
  end
end
