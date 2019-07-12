class Program < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates_associated :phases

  has_many :programs_phase
  has_many :phases, lambda {
    order("programs_phases.position ASC")
  }, through: :programs_phase
  has_many :dlc_stacks
  has_many :language_stacks, through: :dlc_stacks
  has_many :learner_programs
  has_many :bootcampers, through: :learner_programs
  belongs_to :cadence

  def self.get_finalized_programs
    where(save_status: "true").pluck(:name, :id)
  end

  def assessment_options
    assessment = Assessment.new

    {
      assessments: assessment.get_program_assessments_per_phase(id),
      cadence: try(:cadence).try(:name)
    }
  end

  def self.program_details(program_id)
    select(
      :description,
      :holistic_evaluation,
      :cadence_id,
      :estimated_duration
    ).
      where(id: program_id).first
  end

  def self.maximum_holistic_evaluations(program_id)
    program = find_by(id: program_id)
    if program.cadence
      program.estimated_duration / program.cadence.days
    end
  rescue ZeroDivisionError
    0
  end

  def self.program_phases(program_id)
    where(id: program_id).includes(:phases).pluck("phases.name")
  end

  def self.get_submittable_assessments(program_id)
    joins(:phases, phases: :assessments).
      where(id: program_id).
      where.not(assessments: {
                  expectation: "N/A"
                })
  end

  def self.get_program(id)
    find(id)[:name]
  end
end
