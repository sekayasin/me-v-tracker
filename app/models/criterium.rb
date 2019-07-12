class Criterium < ApplicationRecord
  acts_as_paranoid
  has_many :framework_criteria
  has_many :frameworks, through: :framework_criteria
  has_many :assessments, through: :framework_criteria
  has_many :holistic_evaluations
  has_many :holistic_feedback
  has_many :metrics
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  include Descriptions

  def self.get_program_criteria(program_id)
    Program.joins(phases: { assessments: :criterium }).
      where(id: program_id).select(
        "criteria.id, criteria.name, criteria.description, criteria.context"
      ).distinct
  end

  def self.get_criterium_ids(program_id)
    programs = get_program_criteria(program_id)
    criterium = []

    programs.each { |program| criterium << program[:id] }
    criterium
  end

  def self.get_criteria_for_program(program_id)
    criterium = get_criterium_ids(program_id)

    where(id: criterium).
      as_json(include: { frameworks: { only: %i(name id) } })
  end

  def self.get_criteria_metrics_in_program(program_id)
    criterium = get_criterium_ids(program_id)
    Metric.where(criteria_id: criterium).as_json
  end

  def self.get_point_values_for_metrics(program_id)
    criterium = get_criterium_ids(program_id)
    point_ids = Metric.where(criteria_id: criterium).pluck(:point_id)
    Point.where(id: point_ids).as_json
  end

  def self.get_dev_framework_criteria_ids
    where(belongs_to_dev_framework: true).pluck(:id)
  end

  def self.get_all_criteria
    all.distinct.order(:id)
  end

  def self.search(search_term, program_id)
    fields = %w(name description)
    query = fields.map { |field| field + " ILIKE :search_term" }.join(" OR ")
    criterium = get_criterium_ids(program_id)

    where(id: criterium).includes(:frameworks).
      where(query, search_term: "%#{search_term}%").
      as_json(include: { frameworks: { only: %i(name id) } })
  end

  def self.get_program_criteria_for_assessment(program_id)
    criterium = get_criterium_ids(program_id)
    Criterium.order(:id).includes(:frameworks).where(id: criterium)
  end
end
