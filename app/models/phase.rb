class Phase < ApplicationRecord
  has_and_belongs_to_many :assessments, -> { distinct }
  has_many :output_submissions, dependent: :destroy
  has_many :scores
  has_many :feedback, dependent: :destroy
  belongs_to :program
  belongs_to :programs_phase
  validates :name, presence: true

  def self.clone_phases(phase_ids)
    phase_ids.map do |id|
      duped_phase = Phase.find(id).dup
      duped_phase.save
      assessment_ids = Phase.
                       joins(:assessments).
                       where("assessments_phases.phase_id = ?", id).
                       pluck(:assessment_id)
      assessment_ids.each do |assessment_id|
        duped_phase.assessments << Assessment.find(assessment_id)
      end
      duped_phase.id
    end
  end

  def self.find_or_create_phase(phases)
    phases.each do |phase|
      Phase.find_or_create_by(name: phase)
    end
  end

  def self.update_or_create(phase_details)
    details = {
      name: phase_details[:name],
      phase_duration: phase_details[:phase_duration],
      phase_decision_bridge: phase_details[:phase_decision_bridge]
    }
    if phase_details[:id]
      Phase.update(phase_details[:id], details)
    else
      Phase.create(details)
    end
  end

  def self.get_due_date(phase, start_date, offset = 0)
    duration = phase["phase_duration"]
    if start_date.nil? || duration.nil?
      "N/A"
    else
      (offset + duration - 1).business_days.after(
        start_date
      ).strftime("%B %d, %Y")
    end
  end

  def self.group_into_weeks(phases)
    phase_start = 0
    grouped_phases = []
    phases.each do |phase|
      group = phase_start / 5
      grouped_phases[group] = [] unless grouped_phases[group]
      grouped_phases[group] << phase
      phase_start += phase.phase_duration || 0
    end
    grouped_phases
  end

  def get_total_assessments
    assessments.count
  end
end
