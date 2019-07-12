require "fancy_id"

class CycleCenter < ApplicationRecord
  self.primary_key = :cycle_center_id
  self.table_name = :cycles_centers

  validates :center_id, presence: true
  validates :cycle_id, presence: true
  validates :program_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  belongs_to :cycle, foreign_key: :cycle_id
  belongs_to :center, foreign_key: :center_id
  belongs_to :program, foreign_key: :program_id

  has_one :learner_program

  has_many :surveys_pivots, as: :surveyable, class_name: "SurveyPivot"

  has_many :nps_responses,
           dependent: :destroy,
           class_name: "NpsResponse"

  has_many :schedule_feedbacks,
           dependent: :destroy,
           class_name: "ScheduleFeedback"

  has_many :bootcamper_cycle_centers,
           dependent: :destroy

  has_many :bootcampers,
           through: :bootcamper_cycle_centers

  has_one :pitch, dependent: :destroy,
                  class_name: "Pitch",
                  primary_key: "cycle_center_id",
                  foreign_key: "cycle_center_id"

  before_create do
    self.cycle_center_id = generate_id
  end

  scope :active, lambda {
    where("(end_date >= ? ) OR (end_date >= ? )",
          Date.today, 2.business_days.before(Date.today).end_of_day.to_s)
  }

  scope :inactive, lambda {
    where("end_date < ?",
          Date.today)
  }

  def cycle_center_details
    details = {
      cycle: "",
      center: "",
      country: "",
      start_date: start_date,
      end_date: end_date
    }

    if cycle
      details[:cycle] = cycle.cycle
    end

    if center
      details[:center] = center.name
      details[:country] = center.country
    end

    details
  end

  def self.ongoing_bootcamp(center_id)
    CycleCenter.where(
      center_id: center_id
    ).where("end_date > ?", Date.today.to_s).first
  end

  def self.active?(cycle_center_id)
    cycle_center = CycleCenter.find_by(cycle_center_id: cycle_center_id)
    end_date = cycle_center.end_date.presence
    !!end_date && Time.now < end_date
  end

  def self.active_for_admin?(cycle_center_id)
    cycle_center = CycleCenter.find_by(cycle_center_id: cycle_center_id)
    end_date = cycle_center.end_date.presence
    !!end_date && Time.now < 2.business_days.after(end_date).end_of_day
  end

  def self.get_or_create_cycle_center(learner_program)
    cycle = Cycle.find_or_create_by(cycle: learner_program[:cycle])
    center = Center.find_or_create_by(name: learner_program[:city],
                                      country: learner_program[:country])
    cycle_center = CycleCenter.find_by(cycle: cycle, center: center)
    if cycle_center.nil?
      cycle_center_details = Hash.new
      cycle_center_details[:cycle] = cycle
      cycle_center_details[:center] = center
      cycle_center_details[:start_date] = learner_program[:start_date]
      cycle_center_details[:end_date] = learner_program[:end_date]
      cycle_center_details[:program_id] = learner_program[:program_id]
      cycle_center = CycleCenter.create cycle_center_details
    end
    cycle_center
  end

  def bootcampers
    LearnerProgram.where(cycle_center: self).
      includes(:bootcamper).map(&:bootcamper)
  end
end
