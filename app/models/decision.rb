class Decision < ApplicationRecord
  belongs_to :learner_program, foreign_key: "learner_programs_id"
  belongs_to :decision_reason

  validates :decision_stage, presence: true
  validates_presence_of :learner_program
  validates_presence_of :decision_reason

  def self.get_decision_by_stage(
    learner_program_id,
    decision_stage
  )
    includes(:learner_program).find_by(
      learner_programs: { id: learner_program_id },
      decision_stage: decision_stage
    )
  end

  def self.get_decisions(learner_program_id)
    includes(
      :learner_program, :decision_reason
    ).where(learner_programs_id: learner_program_id)
  end

  def self.save_decision(learner_program_id, stage, reasons_ids, comment)
    delete_stage_reasons(learner_program_id, stage)

    reasons_ids&.each do |reason_id|
      create(
        learner_programs_id: learner_program_id,
        decision_stage: stage,
        decision_reason_id: reason_id,
        comment: comment
      )
    end
  end

  def self.delete_bootcamper_reasons(learner_program_id, stage = nil)
    if stage
      delete_stage_reasons(learner_program_id, stage)
    else
      bootcamper_reasons_ids = where(learner_programs_id: learner_program_id)
      delete bootcamper_reasons_ids
    end
  end

  def self.delete_stage_reasons(learner_program_id, stage)
    stage_reasons_ids = get_ids(learner_program_id, stage)

    if stage_reasons_ids
      delete stage_reasons_ids
    end
  end

  def self.get_ids(learner_program_id, stage)
    bootcamper_reasons_ids = where(
      learner_programs_id: learner_program_id,
      decision_stage: stage
    )

    unless bootcamper_reasons_ids.empty?
      bootcamper_reasons_ids.pluck(:id)
    end
  end
end
