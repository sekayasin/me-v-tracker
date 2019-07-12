class Point < ApplicationRecord
  has_many :metrics
  validates :value, presence: true
  validates :context, presence: true, uniqueness: true

  def self.get_criteria_points_metrics(program_id)
    criteria_ids = Criterium.get_criterium_ids(program_id)
    joins(:metrics).where(metrics: { criteria_id: criteria_ids }).select(
      'points.id as id, points.value as value,
      metrics.description as description, metrics.criteria_id as criteria_id'
    )
  end
end
