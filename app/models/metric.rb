class Metric < ApplicationRecord
  belongs_to :point
  belongs_to :assessment, -> { with_deleted }, inverse_of: :metrics
  belongs_to :criterium, -> { with_deleted }
  validates :point_id, presence: true
  validates :description, presence: true
  before_save :check_and_delete_if_exists

  def check_and_delete_if_exists
    Metric.where(assessment_id: assessment_id,
                 point_id: point_id,
                 criteria_id: nil).delete_all
  end
end
