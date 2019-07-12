class ProgramsPhase < ApplicationRecord
  belongs_to :program
  belongs_to :phase
  has_many :assessments, -> { with_deleted }, through: :phase

  def self.get_phase_assessments_given_program_id(program_id)
    where(program_id: program_id).includes(phase: :assessments)
  end

  def self.update_or_create(program_id, phase_id, position)
    program_phase = ProgramsPhase.find_or_create_by(
      program_id: program_id,
      phase_id: phase_id
    )
    ProgramsPhase.update(program_phase.id, position: position)
  end

  def self.delete_all_except(program_id, phases)
    phase_ids = phases.map { |phase| phase[:id] }
    ProgramsPhase.
      where(program_id: program_id).where.not(phase_id: phase_ids).delete_all
  end
end
